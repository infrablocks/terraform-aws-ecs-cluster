variable "region" {}

variable "component" {}
variable "deployment_identifier" {}

variable "vpc_cidr" {}

variable "availability_zones" {
  type = list(string)
}

variable "include_asg_capacity_provider" {
  default = "no"
}

variable "security_groups" {
  default = []
}
