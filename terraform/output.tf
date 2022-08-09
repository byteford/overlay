output "api_url" {
  value = aws_apigatewayv2_api.this.api_endpoint
}

output "ws_url" {
  value = aws_apigatewayv2_api.ws.api_endpoint
}