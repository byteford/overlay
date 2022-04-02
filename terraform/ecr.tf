resource "aws_ecr_repository" "lowerthird" {
  name                 = "lowerthird_genirator"
  image_tag_mutability = "MUTABLE"
}