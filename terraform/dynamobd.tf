resource "aws_dynamodb_table" "lowerthird" {
  name         = "lowerthird"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Index"

  attribute {
    name = "Index"
    type = "S"
  }

}

resource "aws_dynamodb_table" "overlay" {
  name         = "overlay"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Index"

  attribute {
    name = "Index"
    type = "S"
  }

}