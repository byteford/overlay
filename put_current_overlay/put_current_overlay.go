package main

import (
	"context"
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

type Item struct {
	Index string
	Value string
}
type QueryStringParameters struct {
	Overlay string `json:"overlay"`
}
type Request struct {
	QSP QueryStringParameters `json:"queryStringParameters"`
}

func HandleRequest(ctx context.Context, req Request) (string, error) {
	tableName := os.Getenv("table")
	if tableName == "" {
		tableName = "current_overlay"
	}

	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	item := Item{
		Index: "0",
		Value: req.QSP.Overlay,
	}
	av, err := dynamodbattribute.MarshalMap(item)
	if err != nil {
		log.Fatal("Get error Marshaling: %s", err)
	}
	svc := dynamodb.New(sess)
	xray.AWS(svc.Client)
	result, err := svc.PutItemWithContext(ctx, &dynamodb.PutItemInput{
		TableName: aws.String(tableName),
		Item:      av,
	})
	if err != nil {
		log.Fatalf("Got error calling getItem: %s", err)
	}
	return fmt.Sprintf("success %s", result), nil
}

func main() {
	lambda.Start(HandleRequest)
}
