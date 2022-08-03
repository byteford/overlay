variable "bucket_location" {
  type = string
}
variable "image_key" {
  type = string
}
variable "font_key" {
  type = string
}

variable "presenters" {
  type = list(object({
    index  = string
    name   = string
    role   = string
    social = string
  }))
  default = [{
    index  = "0"
    name   = "James Sandford"
    role   = "Delivery Consultant"
    social = "in/Byteford"
    },
    {
      index  = "1"
      name   = "Grace Tree"
      role   = "Delivery Consultant"
      social = "in/TreeOfGrace"
    }
  ]
}