data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "ecs_cluster" {
  source = "../../../../"

  region = var.region
  vpc_id = data.terraform_remote_state.prerequisites.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.prerequisites.outputs.private_subnet_ids

  component = var.component
  deployment_identifier = var.deployment_identifier

  cluster_name = var.cluster_name
  cluster_instance_ssh_public_key_path = var.cluster_instance_ssh_public_key_path
  cluster_instance_type = var.cluster_instance_type
  cluster_instance_amis = var.cluster_instance_amis
  cluster_instance_root_block_device_size = var.cluster_instance_root_block_device_size

  cluster_minimum_size = var.cluster_minimum_size
  cluster_maximum_size = var.cluster_maximum_size
  cluster_desired_capacity = var.cluster_desired_capacity

  security_groups = var.security_groups

  include_default_ingress_rule = var.include_default_ingress_rule
  include_default_egress_rule = var.include_default_egress_rule

  allowed_cidrs = var.allowed_cidrs
  egress_cidrs = var.egress_cidrs
}
