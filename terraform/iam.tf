resource "aws_iam_user" "deployment" {
  name = "overlay_deployment"
  
}

resource "aws_iam_user_policy" "deployment" {
  user = aws_iam_user.deployment.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Action = "lambda:*"
            Resource = "*"
        }
    ]
  })
}