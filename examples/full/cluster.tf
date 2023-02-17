module "ecs_cluster" {
  source = "../../"

  region     = "eu-west-2"
  vpc_id     = module.base_network.vpc_id
  subnet_ids = module.base_network.private_subnet_ids

  component             = var.component
  deployment_identifier = var.deployment_identifier

  cluster_name = "services"
  cluster_instance_type = "t2.small"

  cluster_minimum_size = 2
  cluster_maximum_size = 10
  cluster_desired_capacity = 4

  cluster_instance_root_block_device_size = 30
  cluster_instance_root_block_device_type = "standard"
  cluster_instance_root_block_device_path = "/dev/xvda"

  cluster_log_group_retention = 0

  enable_detailed_monitoring = true

  security_groups = aws_security_group.custom_security_group[*].id

  include_asg_capacity_provider = "yes"
}
