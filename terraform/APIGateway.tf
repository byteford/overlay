resource "aws_apigatewayv2_api" "this" {
  name          = "overlay"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "overlay" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "overlay"
  auto_deploy = true
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