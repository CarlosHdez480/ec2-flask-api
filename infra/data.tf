data "aws_ami" "amazon-linux-2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  owners = ["amazon"]
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}