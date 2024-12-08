resource "aws_ecr_repository" "flask_api" {
  name = var.repository_name
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
  image_tag_mutability = "MUTABLE"
}
