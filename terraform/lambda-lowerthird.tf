resource "aws_iam_role" "lowerthird_generator" {
  name = "lowerthird_generator"

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

resource "aws_iam_policy" "lowerthird_generator" {
  name = "lowerthird_generator"
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
          "xray:GetSamplingStatisticSummaries",
          "xray:PutTelemetryRecords",
          "xray:GetTraceGraph",
          "xray:GetServiceGraph",
          "xray:GetInsightImpactGraph",
          "xray:GetInsightSummaries",
          "xray:GetSamplingTargets",
          "xray:PutTraceSegments",
          "xray:GetTimeSeriesServiceStatistics",
          "xray:GetEncryptionConfig",
          "xray:GetSamplingRules",
          "xray:GetInsight",
          "xray:GetInsightEvents",
          "xray:GetTraceSummaries"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_location}/*"
        ]
        Effect = "Allow"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lowerthird_generator" {
  role       = aws_iam_role.lowerthird_generator.name
  policy_arn = aws_iam_policy.lowerthird_generator.arn
}
resource "aws_lambda_function" "lowerthird_generator" {
  image_uri     = "${aws_ecr_repository.lowerthird.repository_url}:latest"
  function_name = "lowerthird_generator"
  role          = aws_iam_role.lowerthird_generator.arn
  package_type  = "Image"
  timeout       = 10
  environment {
    variables = {
      font_bucket  = var.bucket_location
      font_key     = var.font_key
      image_bucket = var.bucket_location
      image_key    = var.image_key
    }
  }
  tracing_config {
    mode = "Active"
  }
}
resource "aws_lambda_permission" "lowerthird_generator" {
  statement_id  = "apiGatewayallow"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lowerthird_generator.function_name

  principal = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}