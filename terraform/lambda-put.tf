resource "aws_iam_role" "put_current_overlay" {
  name = "put_current_overlay"

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

resource "aws_iam_policy" "put_current_overlay" {
  name = "put_current_overlay"
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
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ]
        Resource = [
          aws_dynamodb_table.current_overlay.arn
        ]
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "put_current_overlay" {
  role       = aws_iam_role.put_current_overlay.name
  policy_arn = aws_iam_policy.put_current_overlay.arn
}
/*
data "archive_file" "put_current_overlay" {
  type        = "zip"
  source_file = "../put_current_overlay/put_current_overlay.py"
  output_path = "../put_current_overlay/put_current_overlay.zip"
}
*/
resource "aws_lambda_function" "put_current_overlay" {
  filename         = "../put_current_overlay/put_current_overlay.zip"
  function_name    = "put_current_overlay"
  role             = aws_iam_role.put_current_overlay.arn
  timeout          = 10
  handler          = "put_current_overlay"
  runtime          = "go1.x"
  source_code_hash = sha256("Not Used")

  environment {
    variables = {
      overlay_table = aws_dynamodb_table.current_overlay.name

    }
  }
  tracing_config {
    mode = "Active"
  }
  lifecycle {
    ignore_changes = [
      source_code_hash,
      filename
    ]
  }
}

resource "aws_lambda_permission" "put_current_overlay" {
  statement_id  = "apiGatewayallow"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.put_current_overlay.function_name

  principal = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}