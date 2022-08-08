data "aws_lambda_layer_version" "xray" {
  layer_name = "aws_xray_sdk"
}
data "aws_lambda_layer_version" "pillow" {
  layer_name = "pillow"
}