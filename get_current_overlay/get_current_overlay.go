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

type Item struct {
	Index string
	Value string
}

func HandleRequest(ctx context.Context) (string, error) {
	tableName := os.Getenv("table")
	if tableName == "" {
		tableName = "current_overlay"
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
				S: aws.String("0"),
			},
		},
	})
	if err != nil {
		log.Fatalf("Got error calling getItem: %s", err)
	}
	if result.Item == nil {
		return "", errors.New("Could not find")
	}

	item := Item{}

	err = dynamodbattribute.UnmarshalMap(result.Item, &item)
	if err != nil {
		panic(fmt.Sprintf("Failed to unmarshal Record, %v", err))
	}
	return fmt.Sprintf("%s", item.Value), nil
}

func main() {
	lambda.Start(HandleRequest)
}
