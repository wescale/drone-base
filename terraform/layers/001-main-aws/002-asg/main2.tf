
resource "aws_launch_configuration" "launch_conf" {
  name_prefix = "${var.group}-${var.env}-${var.region}"
  image_id = "${data.aws_ami.debian.id}"
  instance_type = "${var.instance_type}"
  key_name = "pub-key"
  # key_name = "${var.group}-${var.env}-${var.region}"
  associate_public_ip_address = true
  security_groups = [
    "${aws_security_group.asg_ingress.id}"
  ]
  ebs_optimized = false
  user_data = "${data.template_file.user-data.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.asg_profile2.name}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  availability_zones = [
    "${var.region}a",
    "${var.region}b"
  ]
  name_prefix = "${var.group}-${var.env}-${var.region}-asg"
  min_size = "1"
  max_size = "1"
  desired_capacity = "1"
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true
  vpc_zone_identifier = [
    "${data.terraform_remote_state.vpc.outputs.public_subnet_id_a}",
    "${data.terraform_remote_state.vpc.outputs.public_subnet_id_b}"
  ]
  launch_configuration = "${aws_launch_configuration.launch_conf.name}"
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key = "Name"
    value = "${var.group}-${var.env}-${var.region}-instance"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "asg_ingress" {
  name_prefix = "${var.group}-${var.env}-${var.region}-asg-ingress"
  vpc_id = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["${var.ingress_cidr}"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_iam_instance_profile" "asg_profile2" {
  name = "asg-profile2"
  role = "${aws_iam_role.asg_role2.name}"
}

resource "aws_iam_role" "asg_role2" {
  name = "asg-role2"
  path = "/"
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

resource "aws_iam_role_policy" "asg_main_policy" {
  name = "asg-main-policy"
  role = "${aws_iam_role.asg_role2.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:*",
                "secretsmanager:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}
