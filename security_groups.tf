resource "aws_security_group" "cluster" {
  name = "${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  description = "Container access for component: ${var.component}, deployment: ${var.deployment_identifier}, cluster: ${var.cluster_name}"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 1
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      "${var.private_network_cidr}"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags {
    Name = "${var.component}-${var.deployment_identifier}-${var.cluster_name}"
    Component = "${var.component}"
    DeploymentIdentifier = "${var.deployment_identifier}"
    ClusterName = "${var.cluster_name}"
  }
}