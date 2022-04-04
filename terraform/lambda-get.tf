resource "aws_iam_role" "get_lowerthird" {
  name = "get_lowerthird"

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

resource "aws_iam_policy" "get_lowerthird" {
  name = "get_lowerthird"
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
          "dynamodb:GetItem"
        ]
        Resource = [
          aws_dynamodb_table.lowerthird.arn
        ]
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "get_lowerthird" {
  role       = aws_iam_role.get_lowerthird.name
  policy_arn = aws_iam_policy.get_lowerthird.arn
}

data "archive_file" "get_lowerthird" {
  type        = "zip"
  source_file = "../get_lower_third/get_lowerthird.py"
  output_path = "../get_lower_third/get_lowerthird.zip"
}

resource "aws_lambda_function" "get_lowerthird" {
  filename         = data.archive_file.overlay_generator.output_path
  function_name    = "get_lowerthird"
  role             = aws_iam_role.overlay_generator.arn
  timeout          = 10
  handler          = "get_lowerthird.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.overlay_generator.output_base64sha256
  environment {
    variables = {
      lowerthird_table = aws_dynamodb_table.lowerthird.name
    }
  }
  tracing_config {
    mode = "Active"
  }

}

resource "aws_lambda_permission" "get_lowerthird" {
  statement_id  = "apiGatewayallow"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_lowerthird.function_name

  principal = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}


resource "aws_iam_role" "get_overlay" {
  name = "get_overlay"

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

resource "aws_iam_policy" "get_overlay" {
  name = "get_overlay"
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
          "dynamodb:GetItem"
        ]
        Resource = [
          aws_dynamodb_table.overlay.arn
        ]
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "get_overlay" {
  role       = aws_iam_role.get_overlay.name
  policy_arn = aws_iam_policy.get_overlay.arn
}

data "archive_file" "get_overlay" {
  type        = "zip"
  source_file = "../get_overlay/get_overlay.py"
  output_path = "../get_overlay/get_overlay.zip"
}

resource "aws_lambda_function" "get_overlay" {
  filename         = data.archive_file.overlay_generator.output_path
  function_name    = "get_overlay"
  role             = aws_iam_role.overlay_generator.arn
  timeout          = 10
  handler          = "get_overlay.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.overlay_generator.output_base64sha256
  environment {
    variables = {
      overlay_table    = aws_dynamodb_table.overlay.name

    }
  }
  tracing_config {
    mode = "Active"
  }

}

resource "aws_lambda_permission" "get_overlay" {
  statement_id  = "apiGatewayallow"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_overlay.function_name

  principal = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}