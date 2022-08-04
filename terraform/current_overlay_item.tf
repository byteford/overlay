resource "aws_dynamodb_table_item" "current_overlay" {
  table_name = aws_dynamodb_table.current_overlay.name
  hash_key   = aws_dynamodb_table.current_overlay.hash_key

  item = jsonencode({
    Index = { S = "0" },
    Value = { S = "0" },
  })
}