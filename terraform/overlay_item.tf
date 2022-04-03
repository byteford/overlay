locals {
  lowerthird_config = {
    M = {
      Name = {
        M = {
          X = {
            S = "100"
          }
          Y = {
            S = "15"
          }
          Font_size = {
            S = "25"
          }
        }
      }
      Role = {
        M = {
          X = {
            S = "92"
          }
          Y = {
            S = "48"
          }
          Font_size = {
            S = "15"
          }
        }
      }
      Social = {
        M = {
          X = {
            S = "87"
          }
          Y = {
            S = "63"
          }
          Font_size = {
            S = "12"
          }
        }
      }
    }
  }
}
resource "aws_dynamodb_table_item" "overlay1" {
  table_name = aws_dynamodb_table.overlay.name
  hash_key   = aws_dynamodb_table.overlay.hash_key

  item = jsonencode({
    Index = { S = "0" },
    Overlay = {
      M = {
        lowerthirdLeft = {
          M = {
            Lowerthird = {
              S = "0"
            }
            Style = {
              S = "top:70%; left:0%; right:70%; position:absolute"
            }
            config = local.lowerthird_config
          }
        }
        lowerthirdRight = {
          M = {
            Lowerthird = {
              S = "1"
            }
            Style = {
              S = "top:70%; left:50%; right:20%; position:absolute"
            }
            config = local.lowerthird_config
          }
        }
      }
    }
  })
}