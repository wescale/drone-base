
resource "aws_subnet" "public_subnet" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "${var.availability_zone}"
  tags = {
    Name = "${var.vpc_name}-${var.availability_zone}-public"
    Description = "${var.vpc_name} public subnet in AZ ${var.availability_zone}"
  }
}

resource "aws_route_table_association" "public_subnet_to_gateway" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  route_table_id = "${var.public_gateway_route_table_id}"
}
