variable "region" {}

variable "component" {}
variable "deployment_identifier" {}

variable "tags" {
  type = map(string)
  default = null
}

variable "cluster_name" {
  default = null
}
variable "cluster_instance_ssh_public_key_path" {
  default = null
}
variable "cluster_instance_type" {
  default = null
}
variable "cluster_instance_amis" {
  type = map(string)
  default = null
}
variable "cluster_instance_root_block_device_size" {
  default = null
}
variable "cluster_instance_root_block_device_path" {
  default = null
}

variable "cluster_minimum_size" {
  default = null
}
variable "cluster_maximum_size" {
  default = null
}
variable "cluster_desired_capacity" {
  default = null
}
variable "cluster_log_group_retention" {
  default = null
}
variable "cluster_instance_enable_ebs_volume_encryption" {
  default = null
}
variable "cluster_instance_ebs_volume_kms_key_id" {
  default = null
}

variable "enable_detailed_monitoring" {
  default = null
}

variable "include_default_ingress_rule" {
  default = null
}
variable "include_default_egress_rule" {
  default = null
}

variable "allowed_cidrs" {
  type = list(string)
  default = null
}
variable "egress_cidrs" {
  type = list(string)
  default = null
}

variable "security_groups" {
  type    = list(string)
  default = []
}

variable "enable_container_insights" {
  default = null
}

variable "protect_cluster_instances_from_scale_in" {
  default = null
}

variable "include_asg_capacity_provider" {
  default = null
}
variable "asg_capacity_provider_manage_termination_protection" {
  default = null
}
variable "asg_capacity_provider_manage_scaling" {
  default = null
}
variable "asg_capacity_provider_minimum_scaling_step_size" {
  default = null
}
variable "asg_capacity_provider_maximum_scaling_step_size" {
  default = null
}
variable "asg_capacity_provider_target_capacity" {
  default = null
}
