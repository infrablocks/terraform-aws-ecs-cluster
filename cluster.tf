locals {
  cluster_full_name = "${var.component}-${var.deployment_identifier}-${var.cluster_name}"
}

resource "aws_ecs_cluster" "cluster" {
  name = local.cluster_full_name

  tags = local.tags

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  depends_on = [
    null_resource.iam_wait
  ]
}
