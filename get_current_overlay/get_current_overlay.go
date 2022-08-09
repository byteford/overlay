package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
)

type request struct {
}

func HandleRequest(ctx context.Context, name request) (string, error) {
	return fmt.Sprintf("%d", 0), nil
}

func main() {
	lambda.Start(HandleRequest)
}
