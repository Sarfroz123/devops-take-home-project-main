module "label_vpc" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  namespace  = "ll"
  name       = "vpc"
  attributes = ["main"]
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = module.label_vpc.tags
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, 0)
  map_public_ip_on_launch = true
  availability_zone       = var.aws_region
  tags                    = module.label_vpc.tags
}

# Create Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, 1)
  map_public_ip_on_launch = false
  availability_zone = var.aws_region
  tags              = module.label_vpc.tags
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = module.label_vpc.tags
}

# Create Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = module.label_vpc.tags
}

# Associate Public Route Table with Public Subnet
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Create Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = module.label_vpc.tags
}

# Associate Private Route Table with Private Subnet
resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# Create Elastic IP for NAT Gateway

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

#resource "aws_eip" "nat_eip" {
#  vpc = true
#}

# Create NAT Gateway in Public Subnet
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = module.label_vpc.tags
}
