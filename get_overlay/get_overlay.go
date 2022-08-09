package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-xray-sdk-go/xray"
)

type Style struct {
	Right    string `json:"right"`
	Position string `json:"position"`
	Top      string `json:"Top"`
	Left     string `json:"left`
}
type Config struct {
	Image struct {
		Key string
	}
	Name struct {
		X         string
		Y         string
		Font_size string
	}
	Role struct {
		X         string
		Y         string
		Font_size string
	}
	Social struct {
		X         string
		Y         string
		Font_size string
	}
}
type Lowerthird struct {
	Lowerthird string
	Style      Style
	Config     Config `json:"config"`
}
type Overlay struct {
	LowerthirdLeft  []Lowerthird `json:"lowerthirdLeft"`
	LowerthirdRight []Lowerthird `json:"lowerthirdright"`
}
type Item struct {
	Index   string
	Overlay []Overlay
}
type QueryStringParameters struct {
	Overlay string `json:"overlay"`
}
type Request struct {
	QSP QueryStringParameters `json:"queryStringParameters"`
}

func HandleRequest(ctx context.Context, req Request) ([]Overlay, error) {
	tableName := os.Getenv("overlay_table")
	if tableName == "" {
		tableName = "overlay"
	}

	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	svc := dynamodb.New(sess)
	xray.AWS(svc.Client)
	result, err := svc.GetItemWithContext(ctx, &dynamodb.GetItemInput{
		TableName: aws.String(tableName),
		Key: map[string]*dynamodb.AttributeValue{
			"Index": {
				S: aws.String(req.QSP.Overlay),
			},
		},
	})
	if err != nil {
		log.Fatalf("Got error calling getItem: %s", err)
	}
	if result.Item == nil {
		return []Overlay{}, errors.New("could not find")
	}

	item := Item{}
	fmt.Println(item)
	err = dynamodbattribute.UnmarshalMap(result.Item, &item)
	if err != nil {
		panic(fmt.Sprintf("Failed to unmarshal Record, %v", err))
	}
	log.Printf("%v", item.Overlay)
	return item.Overlay, nil
}

func main() {
	lambda.Start(HandleRequest)
}
