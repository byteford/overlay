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
)

type Item struct {
	Index string
	Text  string
}
type QueryStringParameters struct {
	Index string `json:"index"`
}
type Request struct {
	QSP QueryStringParameters `json:"queryStringParameters"`
}

func HandleRequest(ctx context.Context, req Request) (string, error) {
	tableName := os.Getenv("lowerthird_table")
	if tableName == "" {
		tableName = "lowerthird"
	}

	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	svc := dynamodb.New(sess)

	result, err := svc.GetItem(&dynamodb.GetItemInput{
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
	return fmt.Sprintf("%s", item.Text), nil
}

func main() {
	lambda.Start(HandleRequest)
}
