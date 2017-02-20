variable "component" {}
variable "deployment_identifier" {}

variable "region" {}
variable "private_subnet_ids" {}

variable "cluster_name" {
  default = "default"
}

variable "vpc_id" {}

variable "private_network_cidr" {
  default = "10.0.0.0/8"
}

variable "cluster_node_ssh_public_key_path" {}

//variable "minimum_size" {
//  default = 1
//}
//variable "maximum_size" {
//  default = 10
//}
//variable "desired_capacity" {
//  default = 3
//}

//variable "private_network_cidr" {
//  default = "10.0.0.0/8"
//}
//
variable "user_data_template" {
  default = ""
}

variable "instance_type" {
  default = "t2.medium"
}

variable "amis" {
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
