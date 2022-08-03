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
    name   = string
    role   = string
    social = string
  }))
  default = [{
    name   = "James Sandford"
    role   = "Delivery Consultant"
    social = "in/Byteford"
    },
    {
      name   = "Grace Tree"
      role   = "Delivery Consultant"
      social = "in/TreeOfGrace"
    }
  ]
}