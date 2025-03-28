data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "ecs_cluster" {
  source = "../../../.."

  region     = var.region
  vpc_id     = data.terraform_remote_state.prerequisites.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.prerequisites.outputs.private_subnet_ids

  component = var.component

  deployment_identifier = var.deployment_identifier

  tags = var.tags

  cluster_name = var.cluster_name

  include_cluster_instances               = var.include_cluster_instances

  cluster_instance_ssh_public_key_path    = var.cluster_instance_ssh_public_key_path
  cluster_instance_type                   = var.cluster_instance_type
  cluster_instance_ami                    = var.cluster_instance_ami
  cluster_instance_root_block_device_size = var.cluster_instance_root_block_device_size
  cluster_instance_root_block_device_path = var.cluster_instance_root_block_device_path

  cluster_instance_enable_ebs_volume_encryption = var.cluster_instance_enable_ebs_volume_encryption
  cluster_instance_ebs_volume_kms_key_id        = var.cluster_instance_ebs_volume_kms_key_id

  cluster_instance_metadata_options = var.cluster_instance_metadata_options

  cluster_minimum_size     = var.cluster_minimum_size
  cluster_maximum_size     = var.cluster_maximum_size
  cluster_desired_capacity = var.cluster_desired_capacity

  cluster_log_group_retention = var.cluster_log_group_retention

  enable_detailed_monitoring = var.enable_detailed_monitoring

  security_groups = var.security_groups

  include_default_ingress_rule = var.include_default_ingress_rule
  include_default_egress_rule  = var.include_default_egress_rule

  default_ingress_cidrs = var.default_ingress_cidrs
  default_egress_cidrs  = var.default_egress_cidrs

  enable_container_insights = var.enable_container_insights

  protect_cluster_instances_from_scale_in = var.protect_cluster_instances_from_scale_in

  include_asg_capacity_provider                       = var.include_asg_capacity_provider
  asg_capacity_provider_manage_termination_protection = var.asg_capacity_provider_manage_termination_protection
  asg_capacity_provider_manage_scaling                = var.asg_capacity_provider_manage_scaling
  asg_capacity_provider_minimum_scaling_step_size     = var.asg_capacity_provider_minimum_scaling_step_size
  asg_capacity_provider_maximum_scaling_step_size     = var.asg_capacity_provider_maximum_scaling_step_size
  asg_capacity_provider_target_capacity               = var.asg_capacity_provider_target_capacity
  additional_capacity_providers                       = var.additional_capacity_providers
}
