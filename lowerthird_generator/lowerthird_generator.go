package main

import (
	"bytes"
	"context"
	"fmt"
	"image"
	"image/color"
	"image/draw"
	"image/png"
	"log"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"github.com/golang/freetype"
)

//image_key role social name role_size=15&role_loc_x=92&role_loc_y=48&social_size12&social_loc_x=87&social_loc_y=63&name_size=25&name_loc_x=100&name_loc_y=15
type QueryStringParameters struct {
	Image_key  string  `json:"image_key"`
	Role       string  `json:"role"`
	Social     string  `json:"social"`
	Name       string  `json:"name"`
	RoleSize   float64 `json:"role_size"`
	RoleLocX   int     `json:"role_loc_x"`
	RoleLocY   int     `json:"role_loc_y"`
	SocialSize float64 `json:"social_size"`
	SocialLocX int     `json:"social_loc_x"`
	SocialLocY int     `json:"social_loc_y"`
	NameSize   float64 `json:"name_size"`
	NameLocX   int     `json:"name_loc_x"`
	NameLocY   int     `json:"name_loc_y"`
}
type Request struct {
	QSP QueryStringParameters `json:"queryStringParameters"`
}

var region = "eu-west-2"
var cfg = aws.Config{Region: &region}
var sess = session.Must(session.NewSession(&cfg))

func download_from_s3(downloader *s3manager.Downloader, bucket, key string) ([]byte, error) {
	buf := aws.NewWriteAtBuffer([]byte{})
	n, err := downloader.Download(buf, &s3.GetObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(key),
	})
	if err != nil {
		return nil, fmt.Errorf("failed to download file %v", err)
	}
	fmt.Printf("file downloaded, %d bytes\n", n)
	return buf.Bytes(), nil
}
func loadImage(img image.Image) *image.NRGBA {
	bgImg := image.NewNRGBA(image.Rect(0, 0, img.Bounds().Dx(), img.Bounds().Dy()))
	draw.Draw(bgImg, bgImg.Bounds(), &image.Uniform{color.Transparent}, image.Point{}, draw.Src)
	draw.Draw(bgImg, img.Bounds(), img, image.Point{}, draw.Over)
	return bgImg
}
func loadfont(buf []byte, bgImg *image.NRGBA, size float64) *freetype.Context {
	c := freetype.NewContext()
	font, err := freetype.ParseFont(buf)
	if err != nil {
		panic(err)
	}
	c.SetFontSize(size)
	c.SetFont(font)
	c.SetDst(bgImg)
	c.SetClip(bgImg.Bounds())
	c.SetSrc(image.Black)
	return c
}

func addText(img *image.NRGBA, c *freetype.Context, text string, x, y int, size float64) {
	pt := freetype.Pt(x, y+int(c.PointToFixed(size)>>6))
	_, err := c.DrawString(text, pt)
	if err != nil {
		log.Fatal(err)
	}
}

func HandleRequest(ctx context.Context, req Request) (string, error) {
	fmt.Println("started")

	downloader := s3manager.NewDownloader(sess)
	buf, err := download_from_s3(downloader, "dpg-overlay", "dpg lower third300.png")
	if err != nil {
		log.Fatal(err)
	}
	img, filetype, err := image.Decode(bytes.NewReader(buf))
	if err != nil {
		fmt.Println(filetype)
		log.Fatal(err)
	}
	bgImg := loadImage(img)

	buf, err = download_from_s3(downloader, "dpg-overlay", "Roboto-Black.ttf")
	if err != nil {
		log.Fatal(err)
	}
	c := loadfont(buf, bgImg, 15)
	addText(bgImg, c, "Delivery Consoltand", 92, 48, 15)
	var out bytes.Buffer
	png.Encode(&out, bgImg)
	return out.String(), err
}
func main() {
	lambda.Start(HandleRequest)
}
