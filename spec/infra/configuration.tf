variable "region" {}
variable "vpc_cidr" {}
variable "availability_zones" {}
variable "private_network_cidr" {}

variable "component" {}
variable "deployment_identifier" {}

variable "bastion_ami" {}
variable "bastion_ssh_public_key_path" {}
variable "bastion_ssh_allow_cidrs" {}

variable "domain_name" {}
variable "public_zone_id" {}
variable "private_zone_id" {}

variable "cluster_name" {}
variable "cluster_node_ssh_public_key_path" {}
variable "cluster_node_instance_type" {}

variable "cluster_minimum_size" {}
variable "cluster_maximum_size" {}
variable "cluster_desired_capacity" {}

module "base_network" {
  source = "git@github.com:tobyclemson/terraform-aws-base-networking.git//src"

  vpc_cidr = "${var.vpc_cidr}"
  region = "${var.region}"
  availability_zones = "${var.availability_zones}"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  bastion_ami = "${var.bastion_ami}"
  bastion_ssh_public_key_path = "${var.bastion_ssh_public_key_path}"
  bastion_ssh_allow_cidrs = "${var.bastion_ssh_allow_cidrs}"

  domain_name = "${var.domain_name}"
  public_zone_id = "${var.public_zone_id}"
  private_zone_id = "${var.private_zone_id}"
}

module "ecs_cluster" {
  source = "../../src"

  region = "${var.region}"
  vpc_id = "${module.base_network.vpc_id}"
  private_subnet_ids = "${module.base_network.private_subnet_ids}"
  private_network_cidr = "${var.private_network_cidr}"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  cluster_name = "${var.cluster_name}"
  cluster_node_ssh_public_key_path = "${var.cluster_node_ssh_public_key_path}"
  cluster_node_instance_type = "${var.cluster_node_instance_type}"

  cluster_minimum_size = "${var.cluster_minimum_size}"
  cluster_maximum_size = "${var.cluster_maximum_size}"
  cluster_desired_capacity = "${var.cluster_desired_capacity}"
}

output "vpc_id" {
  value = "${module.base_network.vpc_id}"
}

output "vpc_cidr" {
  value = "${module.base_network.vpc_cidr}"
}

output "private_subnet_ids" {
  value = "${module.base_network.private_subnet_ids}"
}

output "cluster_id" {
  value = "${module.ecs_cluster.cluster_id}"
}

output "cluster_name" {
  value = "${module.ecs_cluster.cluster_name}"
}

output "autoscaling_group_name" {
  value = "${module.ecs_cluster.autoscaling_group_name}"
}

output "launch_configuration_name" {
  value = "${module.ecs_cluster.launch_configuration_name}"
}

output "instance_role_arn" {
  value = "${module.ecs_cluster.instance_role_arn}"
}

output "instance_role_id" {
  value = "${module.ecs_cluster.instance_role_id}"
}

output "service_role_arn" {
  value = "${module.ecs_cluster.service_role_arn}"
}

output "service_role_id" {
  value = "${module.ecs_cluster.service_role_id}"
}

output "log_group" {
  value = "${module.ecs_cluster.log_group}"
}