resource "aws_iam_role" "iam_for_lambda" {
  name = "lowerthird"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda" {
  name = "lowerthird"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
        Effect   = "Allow"
      },
      {
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.image_bucket}/${var.image_key}",
          "arn:aws:s3:::${var.font_bucket}/${var.font_key}"
        ]
        Effect = "Allow"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}
resource "aws_lambda_function" "lowerthird_generator" {
  image_uri     = "${aws_ecr_repository.lowerthird.repository_url}:latest"
  function_name = "lowerthird_generator"
  role          = aws_iam_role.iam_for_lambda.arn
  package_type  = "Image"
  timeout       = 10
  environment {
    variables = {
      font_bucket  = var.font_bucket
      font_key     = var.font_key
      image_bucket = var.image_bucket
      image_key    = var.image_key
    }
  }
}

resource "aws_lambda_permission" "this" {
  statement_id  = "apiGatewayallow"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lowerthird_generator.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}