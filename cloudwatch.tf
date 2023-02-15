resource "aws_cloudwatch_log_group" "cluster" {
  name = "/${var.component}/${var.deployment_identifier}/ecs-cluster/${local.cluster_name}"

  retention_in_days = local.cluster_log_group_retention
}
