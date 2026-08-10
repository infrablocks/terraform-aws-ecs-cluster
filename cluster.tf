locals {
  cluster_full_name       = "${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  container_insights_mode = var.container_insights_mode != null ? var.container_insights_mode : (var.enable_container_insights ? "enabled" : "disabled")
}

resource "aws_ecs_cluster" "cluster" {
  name = local.cluster_full_name

  tags = local.tags

  setting {
    name  = "containerInsights"
    value = local.container_insights_mode
  }

  depends_on = [
    null_resource.iam_wait
  ]
}
