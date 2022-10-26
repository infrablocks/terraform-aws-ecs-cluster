locals {
  cluster_full_name = "${var.component}-${var.deployment_identifier}-${local.cluster_name}"
}

resource "aws_ecs_cluster" "cluster" {
  name = local.cluster_full_name

  tags = local.tags

  setting {
    name  = "containerInsights"
    value = local.enable_container_insights == "yes" ? "enabled" : "disabled"
  }

  depends_on = [
    null_resource.iam_wait
  ]
}
