resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.group}-${var.env}-vpc1"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "${var.group}-${var.env}-vpc1-rt"
  }
}

resource "aws_main_route_table_association" "main" {
  route_table_id = aws_route_table.main.id
  vpc_id         = aws_vpc.vpc.id
}

module "zone_a" {
  source                        = "./zone"
  vpc_id                        = aws_vpc.vpc.id
  vpc_name                      = "${var.group}-${var.env}-vpc1"
  availability_zone             = "${var.region}a"
  public_subnet_cidr            = var.public_subnet_cidr_a
  public_gateway_route_table_id = aws_route_table.main.id
}

module "zone_b" {
  source                        = "./zone"
  vpc_id                        = aws_vpc.vpc.id
  vpc_name                      = "${var.group}-${var.env}-vpc1"
  availability_zone             = "${var.region}b"
  public_subnet_cidr            = var.public_subnet_cidr_b
  public_gateway_route_table_id = aws_route_table.main.id
}

