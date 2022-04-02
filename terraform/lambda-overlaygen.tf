resource "aws_iam_role" "overlay_generator" {
  name = "overlay_generator"

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

resource "aws_iam_policy" "overlay_generator" {
  name = "overlay_generator"
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
          "arn:aws:dynamodb:eu-west-2:732192916662:table/lowerthird",
        ]
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "overlay_generator" {
  role       = aws_iam_role.overlay_generator.name
  policy_arn = aws_iam_policy.overlay_generator.arn
}

data "archive_file" "overlay_generator" {
  type        = "zip"
  source_file = "../overlay_generator/overlay_generator.py"
  output_path = "../overlay_generator/overlay_generator.zip"
}

resource "aws_lambda_function" "overlay_generator" {
  filename         = data.archive_file.overlay_generator.output_path
  function_name    = "overlay_generator"
  role             = aws_iam_role.overlay_generator.arn
  timeout          = 10
  handler          = "overlay_generator.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.overlay_generator.output_base64sha256
  environment {
    variables = {
      image_src_url    = format("%s/%s", aws_apigatewayv2_stage.overlay.invoke_url, local.lowerthird_generator_url)
      lowerthird_table = aws_dynamodb_table.lowerthird.name
    }
  }
  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_permission" "overlay_generator" {
  statement_id  = "apiGatewayallow"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.overlay_generator.function_name

  principal = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}