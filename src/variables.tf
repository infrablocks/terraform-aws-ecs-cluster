variable "region" {}
variable "vpc_id" {}
variable "private_subnet_ids" {}
variable "private_network_cidr" {
  default = "10.0.0.0/8"
}

variable "component" {}
variable "deployment_identifier" {}

variable "cluster_name" {
  default = "default"
}
variable "cluster_node_ssh_public_key_path" {}
variable "cluster_node_instance_type" {
  default = "t2.medium"
}
variable "cluster_node_user_data_template" {
  default = ""
}
variable "cluster_node_amis" {
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

variable "cluster_minimum_size" {
  default = 1
}
variable "cluster_maximum_size" {
  default = 10
}
variable "cluster_desired_capacity" {
  default = 3
}
