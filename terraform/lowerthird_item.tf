locals {
  users = [{
    index = "0"
    name   = "James Sandford"
    role   = "Delivery Consultant"
    social = "in/Byteford"
    },
    {
      index = "1"
      name   = "Grace Tree"
      role   = "Delivery Consultant"
      social = "in/TreeOfGrace"
    }
  ]
}

resource "aws_dynamodb_table_item" "lowerthird" {
  for_each   = {for key in local.users: key.name => key}
  table_name = aws_dynamodb_table.lowerthird.name
  hash_key   = aws_dynamodb_table.lowerthird.hash_key

  item = jsonencode({
    Index = {
      S = tostring(index(local.users,each.value))
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