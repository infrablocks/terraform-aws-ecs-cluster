resource "aws_cloudwatch_log_group" "cluster" {
  name = "/${var.component}/${var.deployment_identifier}/ecs-cluster/${var.cluster_name}"

  retention_in_days = var.cluster_log_group_retention
}

resource "aws_cloudwatch_log_group" "execute_command" {
  count = var.enable_execute_command_logging ? 1 : 0

  name = local.execute_command_log_group_name

  retention_in_days = var.execute_command_log_group_retention
  kms_key_id = (
    var.enable_execute_command_cloudwatch_encryption
    ? aws_kms_key.execute_command[0].arn
    : null
  )
}
