variable "vpc_cidr" {}
variable "region" {}
variable "availability_zones" {}

variable "component" {}
variable "deployment_identifier" {}

variable "bastion_ami" {}
variable "bastion_ssh_public_key_path" {}
variable "bastion_ssh_allow_cidrs" {}

variable "domain_name" {}
variable "public_zone_id" {}

variable "cluster_name" {}
variable "instance_type" {}

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
}

module "ecs_cluster" {
  source = "../../src"

  region = "${var.region}"
  private_subnet_ids = "${module.base_network.private_subnet_ids}"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  cluster_name = "${var.cluster_name}"
  instance_type = "${var.instance_type}"
}
