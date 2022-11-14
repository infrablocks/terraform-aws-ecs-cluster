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

  cluster_name                            = var.cluster_name
  cluster_instance_ssh_public_key_path    = var.cluster_instance_ssh_public_key_path
  cluster_instance_type                   = var.cluster_instance_type
  cluster_instance_amis                   = var.cluster_instance_amis
  cluster_instance_root_block_device_size = var.cluster_instance_root_block_device_size

  cluster_minimum_size     = var.cluster_minimum_size
  cluster_maximum_size     = var.cluster_maximum_size
  cluster_desired_capacity = var.cluster_desired_capacity

  security_groups = var.security_groups

  include_default_ingress_rule = var.include_default_ingress_rule
  include_default_egress_rule  = var.include_default_egress_rule

  allowed_cidrs = var.allowed_cidrs
  egress_cidrs  = var.egress_cidrs

  enable_container_insights = var.enable_container_insights

  protect_cluster_instances_from_scale_in = var.protect_cluster_instances_from_scale_in

  include_asg_capacity_provider                       = var.include_asg_capacity_provider
  asg_capacity_provider_manage_termination_protection = var.asg_capacity_provider_manage_termination_protection
  asg_capacity_provider_manage_scaling                = var.asg_capacity_provider_manage_scaling
  asg_capacity_provider_minimum_scaling_step_size     = var.asg_capacity_provider_minimum_scaling_step_size
  asg_capacity_provider_maximum_scaling_step_size     = var.asg_capacity_provider_maximum_scaling_step_size
  asg_capacity_provider_target_capacity               = var.asg_capacity_provider_target_capacity
}
