resource "aws_key_pair" "pub_key" {
  key_name   = "pub-key"
  public_key = "${file("../../../../id_rsa.pub")}"
}

resource "aws_security_group" "bastion_sg" {
  name_prefix = "${var.team}-${var.env}-${var.region}-asg-ingress"
  vpc_id      = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
}

resource "aws_security_group_rule" "ingress_ssh" {
  security_group_id = "${aws_security_group.bastion_sg.id}"

  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${var.ingress_cidr}"]
  type        = "ingress"
}

resource "aws_instance" "k3s_bastion" {
  ami                         = "${data.aws_ami.debian.id}"
  instance_type               = "${var.instance_type}"
  vpc_security_group_ids      = ["${aws_security_group.bastion_sg.id}"]
  subnet_id                   = "${data.terraform_remote_state.vpc.outputs.public_subnet_id_a}"
  associate_public_ip_address = true
  key_name                    = "${aws_key_pair.pub_key.id}"

  tags = {
    Name = "k3s-bastion"
  }
}

resource "aws_launch_configuration" "launch_configuration_master" {
  name_prefix = "launch-configuration-master"

  image_id      = "${data.aws_ami.debian.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.pub_key.id}"

  associate_public_ip_address = true

  security_groups = [
    "${aws_security_group.asg_sg.id}"
  ]

  ebs_optimized = false

  iam_instance_profile = "${aws_iam_instance_profile.asg_profile.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_master" {
  name_prefix = "asg-master"

  min_size                  = "1"
  max_size                  = "1"
  desired_capacity          = "1"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true

  vpc_zone_identifier = [
    "${data.terraform_remote_state.vpc.outputs.public_subnet_id_a}",
    "${data.terraform_remote_state.vpc.outputs.public_subnet_id_b}"
  ]

  launch_configuration = "${aws_launch_configuration.launch_configuration_master.name}"

  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name"
    value               = "k3s-master"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "launch_configuration_nodes" {
  name_prefix = "launch-configuration-nodes"

  image_id      = "${data.aws_ami.debian.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.pub_key.id}"

  associate_public_ip_address = true

  security_groups = [
    "${aws_security_group.asg_sg.id}"
  ]

  ebs_optimized = false

  iam_instance_profile = "${aws_iam_instance_profile.asg_profile.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_nodes" {
  name_prefix = "asg-nodes"

  min_size                  = "1"
  max_size                  = "1"
  desired_capacity          = "1"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true

  vpc_zone_identifier = [
    "${data.terraform_remote_state.vpc.outputs.public_subnet_id_a}",
    "${data.terraform_remote_state.vpc.outputs.public_subnet_id_b}"
  ]

  launch_configuration = "${aws_launch_configuration.launch_configuration_nodes.name}"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "k3s-node"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "asg_sg" {
  name_prefix = "${var.team}-${var.env}-${var.region}-asg-ingress"
  vpc_id      = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
}

resource "aws_security_group_rule" "ingress_http" {
  security_group_id = "${aws_security_group.asg_sg.id}"

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  type        = "ingress"
}

resource "aws_security_group_rule" "ingress_https" {
  security_group_id = "${aws_security_group.asg_sg.id}"

  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  type        = "ingress"
}

resource "aws_security_group_rule" "egress_all" {
  security_group_id = "${aws_security_group.asg_sg.id}"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  type        = "egress"
}

resource "aws_iam_instance_profile" "asg_profile" {
  name = "asg-profile"
  role = "${aws_iam_role.asg_role.name}"
}

resource "aws_iam_role" "asg_role" {
  name               = "asg-role"
  path               = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
