variable "team" {}
variable "env" {}
variable "region" {}
variable "drone" {}

variable "instance_type" {
  default = "t2.nano"
}
variable "ingress_cidr" {}

variable "vpc_cidr" {
  default = "11.0.0.0/16"
}

data "aws_ami" "debian" {
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-gp2*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["379101102735"] # Debian Project
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.team}-${var.env}-${var.region}-tfstate"
    key = "001-vpc.tfstate"
    region = "${var.region}"
  }
}
