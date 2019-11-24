package main

import (
	"encoding/json"
	"github.com/aws/aws-lambda-go/events"
	"testing"
)

type testCase struct {
	input  string
	output string
	status int
}

func TestHandler(t *testing.T) {
	cases := []testCase{
		testCase{
			input:  "",
			output: "pong",
			status: 200,
		},

		testCase{
			input:  "foo",
			output: "foo",
			status: 200,
		},
	}

	for _, tc := range cases {

		req := events.APIGatewayProxyRequest{
			HTTPMethod:            "GET",
			QueryStringParameters: make(map[string]string),
		}
		req.QueryStringParameters["ping"] = tc.input

		res, err := handler(nil, req)
		if err != nil {
			t.Fatalf("expected err to be nil, got %s", err)
		}

		if res.StatusCode != tc.status {
			t.Fatalf("expected statusCode %v, got %v instead", tc.status, res.StatusCode)
		}

		var body ping
		err = json.Unmarshal([]byte(res.Body), &body)
		if err != nil {
			t.Fatalf("expected err to be nil, got %s", err)
		}

		if body.Ping != tc.output {
			t.Fatalf("expected %s to equal pong", body.Ping)
		}
	}

}
