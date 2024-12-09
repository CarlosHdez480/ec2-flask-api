# Retrieve VPC with default tenancy
data "aws_vpcs" "default_tenancy_vpcs" {
  filter {
    name   = "instance-tenancy"
    values = ["default"]
  }
}

data "aws_vpc" "default_tenancy_vpc" {
  id = data.aws_vpcs.default_tenancy_vpcs.ids[0]
}

# Retrieve all public subnets in the VPC
data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_tenancy_vpc.id]
  }
}