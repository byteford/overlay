resource "aws_apigatewayv2_api" "this" {
  name          = "overlay"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_stage" "overlay" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "overlay"
  auto_deploy = true
  default_route_settings {
    detailed_metrics_enabled = true
    throttling_burst_limit   = 100
    throttling_rate_limit    = 100
  }
}


resource "aws_apigatewayv2_route" "lowerthird" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /${local.lowerthird_generator_url}"

  target = "integrations/${aws_apigatewayv2_integration.lowerthird.id}"
}

resource "aws_apigatewayv2_integration" "lowerthird" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  payload_format_version = "2.0"
  integration_uri        = aws_lambda_function.lowerthird_generator.invoke_arn
}

resource "aws_apigatewayv2_route" "overlay" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "$default"

  target = "integrations/${aws_apigatewayv2_integration.overlay.id}"
}

resource "aws_apigatewayv2_integration" "overlay" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  payload_format_version = "2.0"
  integration_uri        = aws_lambda_function.overlay_generator.invoke_arn
}

resource "aws_apigatewayv2_route" "get_lowerthird" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /${local.get_lowerthird_url}"

  target = "integrations/${aws_apigatewayv2_integration.overlay.id}"
}

resource "aws_apigatewayv2_integration" "get_lowerthird" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  payload_format_version = "2.0"
  integration_uri        = aws_lambda_function.get_lowerthird.invoke_arn
}

resource "aws_apigatewayv2_route" "get_overlay" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /${local.get_overlay_url}"

  target = "integrations/${aws_apigatewayv2_integration.overlay.id}"
}

resource "aws_apigatewayv2_integration" "get_overlay" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  payload_format_version = "2.0"
  integration_uri        = aws_lambda_function.get_overlay.invoke_arn
}