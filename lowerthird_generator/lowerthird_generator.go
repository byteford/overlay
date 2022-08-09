package main

import (
	"bytes"
	"context"
	"encoding/base64"
	"fmt"
	"image"
	"image/color"
	"image/draw"
	"image/png"
	"log"
	"os"
	"strconv"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"github.com/aws/aws-xray-sdk-go/xray"
	"github.com/golang/freetype"
)

//image_key role social name role_size=15&role_loc_x=92&role_loc_y=48&social_size12&social_loc_x=87&social_loc_y=63&name_size=25&name_loc_x=100&name_loc_y=15
type QueryStringParameters struct {
	Image_key  string `json:"image_key,omitempty"`
	Role       string `json:"role,omitempty"`
	Social     string `json:"social,omitempty"`
	Name       string `json:"name,omitempty"`
	RoleSize   string `json:"role_size,omitempty"`
	RoleLocX   string `json:"role_loc_x,omitempty"`
	RoleLocY   string `json:"role_loc_y,omitempty"`
	SocialSize string `json:"social_size,omitempty"`
	SocialLocX string `json:"social_loc_x,omitempty"`
	SocialLocY string `json:"social_loc_y,omitempty"`
	NameSize   string `json:"name_size,omitempty"`
	NameLocX   string `json:"name_loc_x,omitempty"`
	NameLocY   string `json:"name_loc_y,omitempty"`
}
type Request struct {
	QSP QueryStringParameters `json:"queryStringParameters"`
}

func download_from_s3(ctx context.Context, downloader *s3manager.Downloader, bucket, key string) ([]byte, error) {
	buf := aws.NewWriteAtBuffer([]byte{})
	n, err := downloader.DownloadWithContext(ctx, buf, &s3.GetObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(key),
	})
	if err != nil {
		return nil, fmt.Errorf("failed to download file %v", err)
	}
	fmt.Printf("file downloaded, %d bytes\n", n)
	return buf.Bytes(), nil
}
func loadImage(img image.Image) image.NRGBA {
	bgImg := image.NewNRGBA(image.Rect(0, 0, img.Bounds().Dx(), img.Bounds().Dy()))
	draw.Draw(bgImg, bgImg.Bounds(), &image.Uniform{color.Transparent}, image.Point{}, draw.Src)
	draw.Draw(bgImg, img.Bounds(), img, image.Point{}, draw.Over)
	return *bgImg
}
func loadfont(buf []byte, bgImg *image.NRGBA, size float64, colour *image.Uniform) *freetype.Context {
	c := freetype.NewContext()
	font, err := freetype.ParseFont(buf)
	if err != nil {
		panic(err)
	}
	c.SetFontSize(size)
	c.SetFont(font)
	c.SetDst(bgImg)
	c.SetClip(bgImg.Bounds())
	c.SetSrc(colour)
	return c
}

func addText(img *image.NRGBA, c *freetype.Context, text string, x, y int, size float64) {
	pt := freetype.Pt(x, y+int(c.PointToFixed(size)>>6))
	_, err := c.DrawString(text, pt)
	if err != nil {
		log.Fatal(err)
	}
}

func HandleRequest(ctx context.Context, req Request) (events.APIGatewayProxyResponse, error) {
	fmt.Println("started")
	log.Println(req)
	svc := s3.New(session.Must(session.NewSession()))
	xray.AWS(svc.Client)
	downloader := s3manager.NewDownloaderWithClient(svc)
	buf, err := download_from_s3(ctx, downloader, os.Getenv("image_bucket"), req.QSP.Image_key)
	if err != nil {
		log.Fatal(err)
	}
	img, filetype, err := image.Decode(bytes.NewReader(buf))
	if err != nil {
		fmt.Println(filetype)
		log.Fatal(err)
	}
	bgImg := loadImage(img)

	buf, err = download_from_s3(ctx, downloader, os.Getenv("font_bucket"), os.Getenv("font_key"))
	if err != nil {
		log.Fatal(err)
	}

	x, _ := strconv.Atoi(req.QSP.NameLocX)
	y, _ := strconv.Atoi(req.QSP.NameLocY)
	size, _ := strconv.Atoi(req.QSP.NameSize)
	c := loadfont(buf, &bgImg, float64(size), image.Black)
	addText(&bgImg, c, req.QSP.Name, x, y, float64(size))

	x, _ = strconv.Atoi(req.QSP.RoleLocX)
	y, _ = strconv.Atoi(req.QSP.RoleLocY)
	size, _ = strconv.Atoi(req.QSP.RoleSize)
	c = loadfont(buf, &bgImg, float64(size), image.Black)
	addText(&bgImg, c, req.QSP.Role, x, y, float64(size))

	x, _ = strconv.Atoi(req.QSP.SocialLocX)
	y, _ = strconv.Atoi(req.QSP.SocialLocY)
	size, _ = strconv.Atoi(req.QSP.SocialSize)
	c = loadfont(buf, &bgImg, float64(size), image.White)
	addText(&bgImg, c, req.QSP.Social, x, y, float64(size))

	var out bytes.Buffer
	png.Encode(&out, &bgImg)
	return events.APIGatewayProxyResponse{Headers: map[string]string{"Content-type": "image/png"}, Body: base64.StdEncoding.EncodeToString(out.Bytes()), StatusCode: 200, IsBase64Encoded: true}, err
}
func main() {
	lambda.Start(HandleRequest)
}
