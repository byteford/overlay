resource "aws_apigatewayv2_api" "this" {
  name          = "overlay"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id        = aws_apigatewayv2_api.this.id
  name          = "lowerthird"
  auto_deploy   = true
}


resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "$default"

  target = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_integration" "this" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  connection_type  = "INTERNET"
  payload_format_version = "2.0"
  integration_uri    = aws_lambda_function.this.invoke_arn
}