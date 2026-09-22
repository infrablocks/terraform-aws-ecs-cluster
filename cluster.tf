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

  dynamic "configuration" {
    for_each = var.enable_execute_command_logging ? [1] : []
    content {
      execute_command_configuration {
        kms_key_id = aws_kms_key.execute_command[0].arn
        logging    = "OVERRIDE"
        log_configuration {
          cloud_watch_encryption_enabled = var.enable_execute_command_cloudwatch_encryption
          cloud_watch_log_group_name     = aws_cloudwatch_log_group.execute_command[0].name
        }
      }
    }
  }

  depends_on = [
    null_resource.iam_wait
  ]
}
