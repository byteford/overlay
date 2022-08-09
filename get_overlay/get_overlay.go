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
	Right    string `json:"right,omitempty"`
	Position string `json:"position,omitempty"`
	Top      string `json:"top,omitempty"`
	Left     string `json:"left,omitempty"`
}
type Config struct {
	Image *struct {
		Key string `json:"Key,omitempty"`
	} `json:"Image,omitempty"`
	Name *struct {
		X         string `json:"X,omitempty"`
		Y         string `json:"Y,omitempty"`
		Font_size string `json:"Font_size,omitempty"`
	} `json:"Name,omitempty"`
	Role *struct {
		X         string `json:"X,omitempty"`
		Y         string `json:"Y,omitempty"`
		Font_size string `json:"Font_size,omitempty"`
	} `json:"Role,omitempty"`
	Social *struct {
		X         string `json:"X,omitempty"`
		Y         string `json:"Y,omitempty"`
		Font_size string `json:"Font_size,omitempty"`
	} `json:"Social,omitempty"`
}
type Lowerthird struct {
	Lowerthird string  `json:"Lowerthird,omitempty"`
	Style      *Style  `json:"Style,omitempty"`
	Config     *Config `json:"config,omitempty"`
}
type Overlay struct {
	LowerthirdLeft  *Lowerthird `json:"lowerthirdLeft,omitempty"`
	LowerthirdRight *Lowerthird `json:"lowerthirdright,omitempty"`
}
type Item struct {
	Index   string
	Overlay Overlay
}
type QueryStringParameters struct {
	Overlay string `json:"overlay"`
}
type Request struct {
	QSP QueryStringParameters `json:"queryStringParameters"`
}

func HandleRequest(ctx context.Context, req Request) (Overlay, error) {
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
		return Overlay{}, errors.New("could not find")
	}

	item := Item{}
	fmt.Println(result.Item)
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
