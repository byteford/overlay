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

type Text struct {
	Name   string
	Role   string
	Social string
}
type Item struct {
	Index string
	Text  Text
}
type QueryStringParameters struct {
	Index string `json:"index"`
}
type Request struct {
	QSP QueryStringParameters `json:"queryStringParameters"`
}

func HandleRequest(ctx context.Context, req Request) (Text, error) {
	tableName := os.Getenv("lowerthird_table")
	if tableName == "" {
		tableName = "lowerthird"
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
				S: aws.String(req.QSP.Index),
			},
		},
	})
	if err != nil {
		log.Fatalf("Got error calling getItem: %s", err)
	}
	if result.Item == nil {
		return Text{}, errors.New("could not find")
	}

	item := Item{}
	fmt.Println(item)
	err = dynamodbattribute.UnmarshalMap(result.Item, &item)
	if err != nil {
		panic(fmt.Sprintf("Failed to unmarshal Record, %v", err))
	}
	log.Printf("%v", item.Text)
	return item.Text, nil
}

func main() {
	lambda.Start(HandleRequest)
}
