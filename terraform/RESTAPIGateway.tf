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
          produces :["application/json"]
          responses :{
            200:{
              description: "200 response"
              Schema: {
                "$ref" : "#definitions/valuejson"
              }
              headers :{
                Access-Control-Allow-Origin:{
                  type: "string"
                }
              }
            }
          }
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            payloadFormatVersion = "1.0"
            responses:{
              default:{
                statusCode : 200
              }
            }
            passthroughBehavior: "when_no_templates"
            type                 = "AWS"
            uri                  = aws_lambda_function.get_current_overlay.invoke_arn
          }
        }
        post = {
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            payloadFormatVersion = "1.0"
            type                 = "AWS"
            uri                  = aws_lambda_function.put_current_overlay.invoke_arn
          }
        }
      }
      "/${local.lowerthird_generator_url}" = {
        get = {
            x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            payloadFormatVersion = "1.0"
            type                 = "AWS"
            uri                  = aws_lambda_function.lowerthird_generator.invoke_arn
          }
        }
      }
    }
    definitions :{
      valuejson :{
        type: "string"
        properties:{
          Value:{
            type: "string"
          }
        }
      }
      title: "value"
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