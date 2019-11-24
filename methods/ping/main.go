package main

import (
	"context"
	"encoding/json"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

// Ping describes the response structure
type ping struct {
	Ping string `json:ping`
}

func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// get ping query parameter if any
	p, ok := request.QueryStringParameters["ping"]
	if !ok || p == "" {
		p = "pong"
	}

	// construct json and headers
	respHeaders := make(map[string]string)
	respHeaders["Content-Type"] = "application/json"
	status := 200
	respBody, err := json.Marshal(ping{Ping: p})

	if err != nil {
		status = 500
	}

	// return
	return events.APIGatewayProxyResponse{
		StatusCode: status,
		Headers:    respHeaders,
		Body:       string(respBody),
	}, err
}

func main() {
	lambda.Start(handler)
}
