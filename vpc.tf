module "label_vpc" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "vpc"
  attributes = ["main"]
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = module.label_vpc.tags
}

# =========================
# Create your subnets here
# =========================

module "public_subnet" {
  source  = "terraform-aws-modules/subnet/aws"
  version = "3.0.0"

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, 0)  // Example: if VPC CIDR is 192.170.0.0/20, this will create a /24 subnet within it
  map_public_ip_on_launch = true
  availability_zone       = var.aws_region  // Using the region as the availability zone for simplicity, adjust as needed

  tags = module.base_label.tags
}

module "private_subnet" {
  source  = "terraform-aws-modules/subnet/aws"
  version = "3.0.0"

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, 1)  // Example: if VPC CIDR is 192.170.0.0/20, this will create another /24 subnet within it
  map_public_ip_on_launch = false
  availability_zone       = var.aws_region  // Using the region as the availability zone for simplicity, adjust as needed

  tags = module.base_label.tags
}