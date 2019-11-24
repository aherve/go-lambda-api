variable "environment" {}

# API
resource aws_api_gateway_rest_api "api" {
  name       = "go-lambda-api-gateway"
}

module methods {
  source               = "./methods"
  environment          = var.environment
  api_root_resource_id = aws_api_gateway_rest_api.api.root_resource_id
  api_id               = aws_api_gateway_rest_api.api.id
}

# Deploy the api. Manually changing the `updatedAt` variable will trigger a terraform deployment
resource aws_api_gateway_deployment "api" {
  depends_on = [module.methods]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "v1"

  variables = {
    "updatedAt" = "2019-11-24"
  }
}

