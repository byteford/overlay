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
      "/${local.lowerthird_generator_url}" = {
        any = {
            x-amazon-apigateway-integration = {
            httpMethod           = "ANY"
            payloadFormatVersion = "1.0"
            type                 = "AWS_PROXY"
            uri                  = aws_lambda_function.lowerthird_generator.invoke_arn
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

resource "aws_api_gateway_deployment" "overlay" {
  rest_api_id = aws_api_gateway_rest_api.overlay.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.overlay.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "overlay" {
  deployment_id = aws_api_gateway_deployment.overlay.id
  rest_api_id   = aws_api_gateway_rest_api.overlay.id
  stage_name    = "overlay"
}