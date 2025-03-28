resource "aws_ecs_capacity_provider" "autoscaling_group" {
  count = (var.include_cluster_instances && var.include_asg_capacity_provider) ? 1 : 0

  name = "cp-${var.component}-${var.deployment_identifier}-${var.cluster_name}"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.cluster[0].arn

    managed_termination_protection = var.asg_capacity_provider_manage_termination_protection ? "ENABLED" : "DISABLED"

    managed_scaling {
      status = var.asg_capacity_provider_manage_scaling ? "ENABLED" : "DISABLED"
      target_capacity = var.asg_capacity_provider_target_capacity
      minimum_scaling_step_size = var.asg_capacity_provider_minimum_scaling_step_size
      maximum_scaling_step_size = var.asg_capacity_provider_maximum_scaling_step_size
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_providers" {
  count = ((var.include_cluster_instances && var.include_asg_capacity_provider) || length(var.additional_capacity_providers) > 0) ? 1 : 0

  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = var.include_asg_capacity_provider ? [aws_ecs_capacity_provider.autoscaling_group[0].name] : var.additional_capacity_providers
}
