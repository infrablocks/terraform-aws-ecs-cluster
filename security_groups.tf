resource "aws_security_group" "cluster" {
  count = "${length(var.security_groups) == 0 ? 1 : 0}"
  name = "${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  description = "Container access for component: ${var.component}, deployment: ${var.deployment_identifier}, cluster: ${var.cluster_name}"
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "${var.component}-${var.deployment_identifier}-${var.cluster_name}"
    Component = "${var.component}"
    DeploymentIdentifier = "${var.deployment_identifier}"
    ClusterName = "${var.cluster_name}"
  }
}

resource "aws_security_group_rule" "cluster_default_ingress" {
  count = "${var.include_default_ingress_rule == "yes" && length(var.security_groups) == 0 ? 1 : 0}"

  type = "ingress"

  security_group_id = "${element(concat(aws_security_group.cluster.*.id, list("")), 0)}"

  protocol = "tcp"
  from_port = 1
  to_port = 65535

  cidr_blocks = "${var.allowed_cidrs}"
}

resource "aws_security_group_rule" "cluster_default_egress" {
  count = "${var.include_default_egress_rule == "yes" && length(var.security_groups) == 0 ? 1 : 0}"

  type = "egress"

  security_group_id = "${element(concat(aws_security_group.cluster.*.id, list("")), 0)}"

  protocol = "-1"
  from_port = 0
  to_port = 0

  cidr_blocks = "${var.egress_cidrs}"
}