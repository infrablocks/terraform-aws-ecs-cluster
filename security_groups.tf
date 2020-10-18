resource "aws_security_group" "cluster" {
  name = "${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  description = "Container access for component: ${var.component}, deployment: ${var.deployment_identifier}, cluster: ${var.cluster_name}"
  vpc_id = var.vpc_id

  tags = merge(local.tags, {
    Name = "${var.component}-${var.deployment_identifier}-${var.cluster_name}"
    ClusterName = var.cluster_name
  })
}

resource "aws_security_group_rule" "cluster_default_ingress" {
  count = var.include_default_ingress_rule == "yes" ? 1 : 0

  type = "ingress"

  security_group_id = aws_security_group.cluster.id

  protocol = "-1"
  from_port = 0
  to_port = 0

  cidr_blocks = var.allowed_cidrs
}

resource "aws_security_group_rule" "cluster_default_egress" {
  count = var.include_default_egress_rule == "yes" ? 1 : 0

  type = "egress"

  security_group_id = aws_security_group.cluster.id

  protocol = "-1"
  from_port = 0
  to_port = 0

  cidr_blocks = var.egress_cidrs
}