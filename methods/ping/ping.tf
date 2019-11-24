variable environment {}
variable api_id {}
variable api_root_resource_id {}

data aws_region "current" {}
data aws_caller_identity "current" {}

# API
resource aws_api_gateway_resource "ping" {
  parent_id   = var.api_root_resource_id
  path_part   = "ping"
  rest_api_id = var.api_id
}

resource aws_api_gateway_method "ping" {
  api_key_required = false
  authorization    = "NONE"
  http_method      = "GET"
  resource_id      = aws_api_gateway_resource.ping.id
  rest_api_id      = var.api_id
}

resource aws_api_gateway_integration "ping" {
  rest_api_id             = var.api_id
  resource_id             = aws_api_gateway_resource.ping.id
  http_method             = aws_api_gateway_method.ping.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.ping.arn}/invocations"
}

# LAMBDA
resource aws_lambda_permission "api_ping" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ping.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.api_id}/*/${aws_api_gateway_method.ping.http_method}${aws_api_gateway_resource.ping.path}"
}

data archive_file "ping" {
  output_path = "../../methods/ping/main.zip"
  source_file = "../../methods/ping/main"
  type        = "zip"
}

resource aws_lambda_function "ping" {
  filename         = data.archive_file.ping.output_path
  function_name    = "go-lambda-api-ping"
  handler          = "main"
  role             = aws_iam_role.api_ping.arn
  runtime          = "go1.x"
  source_code_hash = data.archive_file.ping.output_base64sha256
  timeout          = 3

}

# IAM
resource aws_iam_role "api_ping" {
  assume_role_policy = data.aws_iam_policy_document.api_ping_role.json
}

resource aws_iam_role_policy "api_ping" {
  policy = data.aws_iam_policy_document.api_ping.json
  role   = aws_iam_role.api_ping.name
}

data aws_iam_policy_document "api_ping_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data aws_iam_policy_document "api_ping" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]
  }
}
