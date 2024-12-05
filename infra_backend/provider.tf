terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0, != 5.71.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      project = "flask-api"
    }
  }
}
