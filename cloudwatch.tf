resource "aws_cloudwatch_log_group" "cluster" {
  name = "/${var.component}/${var.deployment_identifier}/ecs-cluster/${var.cluster_name}"
}
