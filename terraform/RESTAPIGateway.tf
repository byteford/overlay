resource "aws_api_gateway_rest_api" "overlay" {
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "overlay"
      version = "1.0"
    }
    paths = {
      "/current_overlay" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET"
            payloadFormatVersion = "1.0"
            type                 = "AWS_PROXY"
            uri                  = aws_lambda_function.get_current_overlay.invoke_arn
          }
        }
        post = {
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            payloadFormatVersion = "1.0"
            type                 = "AWS_PROXY"
            uri                  = aws_lambda_function.put_current_overlay.invoke_arn
          }
        }
      }
    }
  })

  name = "overlayREST"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}