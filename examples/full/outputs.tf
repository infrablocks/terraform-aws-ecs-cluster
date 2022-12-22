output "cluster_id" {
  value       = module.ecs_cluster.cluster_id
}

output "cluster_name" {
  value       = module.ecs_cluster.cluster_name
}

output "cluster_arn" {
  value       = module.ecs_cluster.cluster_arn
}

output "autoscaling_group_name" {
  value       = module.ecs_cluster.autoscaling_group_name
}

output "autoscaling_group_arn" {
  value       = module.ecs_cluster.autoscaling_group_arn
}

output "launch_template_name" {
  value       = module.ecs_cluster.launch_template_name
}

output "launch_template_id" {
  value       = module.ecs_cluster.launch_template_id
}

output "security_group_id" {
  value       = module.ecs_cluster.security_group_id
}

output "custom_security_group_ids" {
  value = aws_security_group.custom_security_group.*.id
}

output "instance_role_arn" {
  value       = module.ecs_cluster.instance_role_arn
}

output "instance_role_id" {
  value       = module.ecs_cluster.instance_role_id
}

output "instance_policy_arn" {
  value       = module.ecs_cluster.instance_policy_arn
}

output "instance_policy_id" {
  value       = module.ecs_cluster.instance_policy_id
}

output "service_role_arn" {
  value       = module.ecs_cluster.service_role_arn
}

output "service_role_id" {
  value       = module.ecs_cluster.service_role_id
}

output "service_policy_arn" {
  value       = module.ecs_cluster.service_policy_arn
}

output "service_policy_id" {
  value       = module.ecs_cluster.service_policy_id
}

output "log_group" {
  value       = module.ecs_cluster.log_group
}

output "asg_capacity_provider_name" {
  value       = module.ecs_cluster.asg_capacity_provider_name
}
