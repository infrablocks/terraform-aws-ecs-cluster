variable "region" {}

variable "deployment_identifier" {}

variable "policy_name" {}
variable "policy_description" {}

variable "assumable_roles" {
  type = list(string)
  default = null
}