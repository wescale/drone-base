variable "group" {}
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

data "template_file" "user-data" {
  template = <<EOF
#cloud-config
packages:
  - vim
  - git
  - curl
  - htop
  - ncdu
runcmd:
  - 'apt update'
  - 'apt upgrade -y'
  - 'apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common'
  - 'curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -'
  - 'apt-key fingerprint 0EBFCD88'
  - 'add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"'
  - 'apt update'
  - 'apt install -y docker-ce docker-ce-cli containerd.io'
  - 'docker run \
      --volume=/var/run/docker.sock:/var/run/docker.sock \
      --volume=/var/lib/drone:/data \
      --env=DRONE_GITHUB_SERVER=https://github.com \
      --env=DRONE_GITHUB_CLIENT_ID=${var.drone.github_id} \
      --env=DRONE_GITHUB_CLIENT_SECRET=${var.drone.github_secret} \
      --env=DRONE_USER_CREATE=username:${var.drone.username},admin:true \
      --env=DRONE_RUNNER_CAPACITY=2 \
      --env=DRONE_SERVER_HOST=${var.drone.host} \
      --env=DRONE_SERVER_PROTO=https \
      --env=DRONE_TLS_AUTOCERT=true \
      --publish=80:80 \
      --publish=443:443 \
      --restart=always \
      --detach=true \
      --name=drone \
      drone/drone:1'
EOF
}
# # install k3s
# - 'curl -sfL https://get.k3s.io | sh -'

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.group}-${var.env}-${var.region}-tfstate"
    key    = "001-vpc.tfstate"
    region = "${var.region}"
  }
}
