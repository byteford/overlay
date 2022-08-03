resource "aws_iam_role" "ws_connect" {
  name = "ws_connect"

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

resource "aws_iam_policy" "ws_connect" {
  name = "ws_connect"
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
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ws_connect" {
  role       = aws_iam_role.ws_connect.name
  policy_arn = aws_iam_policy.ws_connect.arn
}

data "archive_file" "ws_connect" {
  type        = "zip"
  source_file = "../ws_connect/ws_connect.py"
  output_path = "../ws_connect/ws_connect.zip"
}

resource "aws_lambda_function" "ws_connect" {
  filename         = data.archive_file.ws_connect.output_path
  function_name    = "ws_connect"
  role             = aws_iam_role.ws_connect.arn
  timeout          = 10
  handler          = "ws_connect.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.ws_connect.output_base64sha256
  environment {
    variables = {
      overlay_table = aws_dynamodb_table.current_overlay.name

    }
  }
  tracing_config {
    mode = "Active"
  }

}

resource "aws_lambda_permission" "ws_connect" {
  statement_id  = "apiGatewayallow"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ws_connect.function_name

  principal = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_apigatewayv2_api.ws.execution_arn}/*/*"
}