variable "region" {}

variable "component" {}
variable "deployment_identifier" {}

variable "cluster_name" {}
variable "cluster_instance_ssh_public_key_path" {}
variable "cluster_instance_type" {}
variable "cluster_instance_amis" {
  type = "map"
}
variable "cluster_instance_root_block_device_size" {}

variable "cluster_minimum_size" {}
variable "cluster_maximum_size" {}
variable "cluster_desired_capacity" {}

variable "include_default_ingress_rule" {}
variable "include_default_egress_rule" {}
variable "allowed_cidrs" {
  type = "list"
}
variable "egress_cidrs" {
  type = "list"
}

variable "launch_configuration_create_before_destroy" {}

variable "security_groups" {
  type = "list"
  default = []
}
