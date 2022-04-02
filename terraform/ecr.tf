resource "aws_ecr_repository" "lowerthird" {
  name                 = "lowerthird"
  image_tag_mutability = "MUTABLE"
}