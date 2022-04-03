resource "aws_dynamodb_table_item" "lowerthird2" {
  table_name = aws_dynamodb_table.lowerthird.name
  hash_key   = aws_dynamodb_table.lowerthird.hash_key

  item = jsonencode({
    Index = {
      S = "2"
    }
    FullName = {
      S = "James Sandford"
    }
    Role = {
      S = "Delivery Consultant"
    }
    Social = {
      S = "in/Byteford"
    }
  })
}