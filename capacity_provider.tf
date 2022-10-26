resource "aws_ecs_capacity_provider" "autoscaling_group" {
  count = local.include_asg_capacity_provider == "yes" ? 1 : 0

  name = "cp-${var.component}-${var.deployment_identifier}-${local.cluster_name}"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.cluster.arn

    managed_termination_protection = local.asg_capacity_provider_manage_termination_protection == "yes" ? "ENABLED" : "DISABLED"

    managed_scaling {
      status = local.asg_capacity_provider_manage_scaling == "yes" ? "ENABLED" : "DISABLED"
      target_capacity = local.asg_capacity_provider_target_capacity
      minimum_scaling_step_size = local.asg_capacity_provider_minimum_scaling_step_size
      maximum_scaling_step_size = local.asg_capacity_provider_maximum_scaling_step_size
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_providers" {
  count = local.include_asg_capacity_provider == "yes" ? 1 : 0

  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = local.include_asg_capacity_provider == "yes" ? [aws_ecs_capacity_provider.autoscaling_group[0].name] : []
}
