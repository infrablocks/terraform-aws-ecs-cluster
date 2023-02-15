locals {
  # default for cases when `null` value provided, meaning "use default"
  cluster_name = var.cluster_name == null ? "default" : var.cluster_name
  cluster_instance_type = var.cluster_instance_type == null ? "t2.medium" : var.cluster_instance_type
  cluster_instance_ssh_public_key_path = var.cluster_instance_ssh_public_key_path == null ? "" : var.cluster_instance_ssh_public_key_path
  cluster_instance_root_block_device_size = var.cluster_instance_root_block_device_size == null ? 30 : var.cluster_instance_root_block_device_size
  cluster_instance_root_block_device_type = var.cluster_instance_root_block_device_type == null ? "standard" : var.cluster_instance_root_block_device_type
  cluster_instance_root_block_device_path = var.cluster_instance_root_block_device_path == null ? "/dev/sda1" : var.cluster_instance_root_block_device_path
  cluster_instance_user_data_template = var.cluster_instance_user_data_template == null ? "" : var.cluster_instance_user_data_template

  cluster_instance_amis = var.cluster_instance_amis == null ? {
    af-south-1     = ""
    ap-east-1      = ""
    ap-northeast-1 = ""
    ap-northeast-2 = ""
    ap-northeast-3 = ""
    ap-south-1     = ""
    ap-southeast-1 = ""
    ap-southeast-2 = ""
    ca-central-1   = ""
    cn-north-1     = ""
    cn-northwest-1 = ""
    eu-central-1   = ""
    eu-north-1     = ""
    eu-south-1     = ""
    eu-west-1      = ""
    eu-west-2      = ""
    eu-west-3      = ""
    me-south-1     = ""
    sa-east-1      = ""
    us-east-1      = ""
    us-east-2      = ""
    us-west-1      = ""
    us-west-2      = ""
  } : var.cluster_instance_amis

  cluster_instance_iam_policy_contents = var.cluster_instance_iam_policy_contents == null ? "" : var.cluster_instance_iam_policy_contents
  cluster_service_iam_policy_contents = var.cluster_service_iam_policy_contents == null ? "" : var.cluster_service_iam_policy_contents
  cluster_minimum_size = var.cluster_minimum_size == null ? 1 : var.cluster_minimum_size
  cluster_maximum_size = var.cluster_maximum_size == null ? 10 : var.cluster_maximum_size
  cluster_desired_capacity = var.cluster_desired_capacity == null ? 3 : var.cluster_desired_capacity
  associate_public_ip_addresses = var.associate_public_ip_addresses == null ? "no" : var.associate_public_ip_addresses
  security_groups = var.security_groups == null ? [] : var.security_groups
  include_default_ingress_rule = var.include_default_ingress_rule == null ? "yes" : var.include_default_ingress_rule
  include_default_egress_rule = var.include_default_egress_rule == null ? "yes" : var.include_default_egress_rule
  allowed_cidrs = var.allowed_cidrs == null ? ["10.0.0.0/8"] : var.allowed_cidrs
  egress_cidrs = var.egress_cidrs == null ? ["0.0.0.0/0"] : var.egress_cidrs
  received_tags = var.tags == null ? {} : var.tags
  enable_container_insights = var.enable_container_insights == null ? "no" : var.enable_container_insights
  protect_cluster_instances_from_scale_in = var.protect_cluster_instances_from_scale_in == null ? "no" : var.protect_cluster_instances_from_scale_in
  include_asg_capacity_provider = var.include_asg_capacity_provider == null ? "no" : var.include_asg_capacity_provider
  asg_capacity_provider_manage_termination_protection = var.asg_capacity_provider_manage_termination_protection == null ? "yes" : var.asg_capacity_provider_manage_termination_protection
  asg_capacity_provider_manage_scaling = var.asg_capacity_provider_manage_scaling == null ? "yes" : var.asg_capacity_provider_manage_scaling
  asg_capacity_provider_minimum_scaling_step_size = var.asg_capacity_provider_minimum_scaling_step_size == null ? 1 : var.asg_capacity_provider_minimum_scaling_step_size
  asg_capacity_provider_maximum_scaling_step_size = var.asg_capacity_provider_maximum_scaling_step_size == null ? 1000 : var.asg_capacity_provider_maximum_scaling_step_size
  asg_capacity_provider_target_capacity = var.asg_capacity_provider_target_capacity == null ? 100 : var.asg_capacity_provider_target_capacity
}
