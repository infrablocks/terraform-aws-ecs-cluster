variable "region" {
  description = "The region into which to deploy the cluster."
}
variable "vpc_id" {
  description = "The ID of the VPC into which to deploy the cluster."
}
variable "private_subnet_ids" {
  description = "The IDs of the private subnets for container instances."
}
variable "private_network_cidr" {
  description = "The CIDR of the private network allowed access to containers."
  default = "10.0.0.0/8"
}

variable "component" {
  description = "The component this cluster will contain."
}
variable "deployment_identifier" {
  description = "An identifier for this instantiation."
}

variable "cluster_name" {
  description = "The name of the cluster to create."
  default = "default"
}
variable "cluster_instance_ssh_public_key_path" {
  description = "The path to the public key to use for the container instances."
}
variable "cluster_instance_type" {
  description = "The instance type of the container instances."
  default = "t2.medium"
}
variable "cluster_instance_root_block_device_size" {
  description = "The size in GB of the root block device on cluster instances."
  default = 10
}
variable "cluster_instance_docker_block_device_size" {
  description = "The size in GB of the docker block device on cluster instances."
  default = 100
}
variable "cluster_instance_docker_block_device_name" {
  description = "The name of the docker block device on cluster instances."
  default = "/dev/xvdcz"
}
variable "cluster_instance_user_data_template" {
  description = "The contents of a template for container instance user data."
  default = ""
}
variable "cluster_instance_amis" {
  description = "A map of regions to AMIs for the container instances."
  type = "map"

  default = {
    us-east-1 = "ami-b2df2ca4"
    us-east-2 = "ami-832b0ee6"
    us-west-1 = "ami-dd104dbd"
    us-west-2 = "ami-022b9262"
    eu-west-1 = "ami-a7f2acc1"
    eu-west-2 = "ami-3fb6bc5b"
    eu-central-1 = "ami-ec2be583"
    ap-northeast-1 = "ami-c393d6a4"
    ap-southeast-1 = "ami-a88530cb"
    ap-southeast-2 = "ami-8af8ffe9"
    ca-central-1 = "ami-ead5688"
  }
}
variable "cluster_instance_iam_policy_contents" {
  description = "The contents of the cluster instance IAM policy."
  default = ""
}
variable "cluster_service_iam_policy_contents" {
  description = "The contents of the cluster service IAM policy."
  default = ""
}

variable "cluster_minimum_size" {
  description = "The minimum size of the ECS cluster."
  default = 1
}
variable "cluster_maximum_size" {
  description = "The maximum size of the ECS cluster."
  default = 10
}
variable "cluster_desired_capacity" {
  description = "The desired capacity of the ECS cluster."
  default = 3
}
