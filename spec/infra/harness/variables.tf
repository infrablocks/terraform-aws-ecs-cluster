variable "region" {}

variable "component" {}
variable "deployment_identifier" {}

variable "tags" {
  type = map(string)
}

variable "cluster_name" {}
variable "cluster_instance_ssh_public_key_path" {}
variable "cluster_instance_type" {}
variable "cluster_instance_amis" {
  type = map(string)
}
variable "cluster_instance_root_block_device_size" {}

variable "cluster_minimum_size" {}
variable "cluster_maximum_size" {}
variable "cluster_desired_capacity" {}

variable "include_default_ingress_rule" {}
variable "include_default_egress_rule" {}

variable "allowed_cidrs" {
  type = list(string)
}
variable "egress_cidrs" {
  type = list(string)
}

variable "security_groups" {
  type    = list(string)
  default = []
}

variable "enable_container_insights" {}

variable "protect_cluster_instances_from_scale_in" {}

variable "include_asg_capacity_provider" {}
variable "asg_capacity_provider_manage_termination_protection" {}
variable "asg_capacity_provider_manage_scaling" {}
variable "asg_capacity_provider_minimum_scaling_step_size" {}
variable "asg_capacity_provider_maximum_scaling_step_size" {}
variable "asg_capacity_provider_target_capacity" {}
