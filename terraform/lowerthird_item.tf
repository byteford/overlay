
resource "aws_dynamodb_table_item" "lowerthird" {
  for_each   = { for key in var.presenters : key.name => key }
  table_name = aws_dynamodb_table.lowerthird.name
  hash_key   = aws_dynamodb_table.lowerthird.hash_key

  item = jsonencode({
    Index = {
      S = tostring(index(var.presenters, each.value))
    }
    Text = {
      M = {
        Name = {
          S = each.value.name
        }
        Role = {
          S = each.value.role
        }
        Social = {
          S = each.value.social
        }
      }
    }
  })
}