locals {
  lowerthirdLeft_style = {
    M = {
      right = {
        S = "70%"
      }
      position = {
        S = "absolute"
      },
      top = {
        S = "70%"
      },
      left = {
        S = "0%"
      }
    }
  }
  lowerthirdRight_style = {
    M = {
      right = {
        S = "0%"
      }
      position = {
        S = "absolute"
      },
      top = {
        S = "70%"
      },
      left = {
        S = "70%"
      }
    }
  }
  lowerthird_config = {
    M = {
      Image = {
        M = {
          Key = {
            s = "dpg lower third300.png"
          }
        }
      }
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
              S = "1"
            }
            Style  = local.lowerthirdLeft_style
            config = local.lowerthird_config
          }
        }
      }
    }
  })
}

resource "aws_dynamodb_table_item" "overlay2" {
  table_name = aws_dynamodb_table.overlay.name
  hash_key   = aws_dynamodb_table.overlay.hash_key

  item = jsonencode({
    Index = { S = "1" },
    Overlay = {
      M = {
        lowerthirdLeft = {
          M = {
            Lowerthird = {
              S = "2"
            }
            Style  = local.lowerthirdLeft_style
            config = local.lowerthird_config
          }
        }
      }
    }
  })
}