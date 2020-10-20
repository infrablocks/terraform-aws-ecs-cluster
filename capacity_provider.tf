resource "aws_ecs_capacity_provider" "autoscaling_group" {
  count = var.include_asg_capacity_provider == "yes" ? 1 : 0

  name = "cp-${var.component}-${var.deployment_identifier}-${var.cluster_name}"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.cluster.arn

    managed_termination_protection = var.asg_capacity_provider_manage_termination_protection == "yes" ? "ENABLED" : "DISABLED"

    managed_scaling {
      status = var.asg_capacity_provider_manage_scaling == "yes" ? "ENABLED" : "DISABLED"
      target_capacity = var.asg_capacity_provider_target_capacity
      minimum_scaling_step_size = var.asg_capacity_provider_minimum_scaling_step_size
      maximum_scaling_step_size = var.asg_capacity_provider_maximum_scaling_step_size
    }
  }

  # This is likely to cause issues with any modifications to the capacity
  # provider that require it to be recreated, however, appears to be necessary
  # to allow the capacity provider to be destroyed correctly.
  lifecycle {
    create_before_destroy = true
  }
}
