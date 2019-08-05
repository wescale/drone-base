data "aws_instances" "k3s_master" {
  depends_on = [ "aws_autoscaling_group.asg_master" ]

  instance_tags = {
    Name = "k3s-master"
  }
}

data "aws_instances" "k3s_nodes" {
  depends_on = [ "aws_autoscaling_group.asg_nodes" ]

  instance_tags = {
    Name = "k3s-node"
  }
}

output "k3s_master_ip" {
  value = "${data.aws_instances.k3s_master.private_ips[0]}"
}

output "k3s_node_0_ip" {
  value = "${data.aws_instances.k3s_nodes.private_ips[0]}"
}

output "k3s_bastion_ip" {
  value = "${aws_instance.k3s_bastion.public_ip}"
}

resource "local_file" "ansible_inventory" {
  content = <<EOF
[master]
${data.aws_instances.k3s_master.private_ips[0]} ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q admin@${aws_instance.k3s_bastion.public_ip}"'

[node]
${data.aws_instances.k3s_nodes.private_ips[0]} ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q admin@${aws_instance.k3s_bastion.public_ip}"'

[k3s-cluster:children]
master
node
EOF

  filename = "hosts.ini"
}
