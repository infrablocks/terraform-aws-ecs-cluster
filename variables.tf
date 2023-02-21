variable "region" {
  description = "The region into which to deploy the cluster."
  type        = string
}
variable "vpc_id" {
  description = "The ID of the VPC into which to deploy the cluster."
  type        = string
}
variable "subnet_ids" {
  description = "The IDs of the subnets for container instances."
  type        = list(string)
}

variable "component" {
  description = "The component this cluster will contain."
  type        = string
}
variable "deployment_identifier" {
  description = "An identifier for this instantiation."
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster to create."
  type        = string
  default     = "default"
  nullable    = false
}

variable "cluster_instance_type" {
  description = "The instance type of the container instances."
  type        = string
  default     = "t2.medium"
  nullable    = false
}
variable "cluster_instance_ssh_public_key_path" {
  description = "The path to the public key to use for the container instances."
  type        = string
  default     = null
  nullable    = true
}

variable "cluster_instance_root_block_device_size" {
  description = "The size in GB of the root block device on cluster instances."
  type        = number
  default     = 30
  nullable    = false
}
variable "cluster_instance_root_block_device_type" {
  description = "The type of the root block device on cluster instances ('standard', 'gp2', or 'io1')."
  type        = string
  default     = "standard"
  nullable    = false
}

variable "cluster_instance_root_block_device_path" {
  description = "Path of the instance root block storage volume"
  type        = string
  default     = "/dev/xvda"
  nullable    = false
}

variable "cluster_instance_user_data_template" {
  description = "The contents of a template for container instance user data."
  type        = string
  default     = ""
  nullable    = false
}

variable "cluster_instance_ami" {
  description = "AMI for the container instances."
  type        = string

  default     = ""
  nullable    = false
}

variable "cluster_instance_iam_policy_contents" {
  description = "The contents of the cluster instance IAM policy."
  type        = string
  default     = ""
  nullable    = false
}
variable "cluster_service_iam_policy_contents" {
  description = "The contents of the cluster service IAM policy."
  type        = string
  default     = ""
  nullable    = false
}

variable "cluster_minimum_size" {
  description = "The minimum size of the ECS cluster."
  type        = string
  default     = 1
  nullable    = false
}
variable "cluster_maximum_size" {
  description = "The maximum size of the ECS cluster."
  type        = string
  default     = 10
  nullable    = false
}
variable "cluster_desired_capacity" {
  description = "The desired capacity of the ECS cluster."
  type        = string
  default     = 3
  nullable    = false
}

variable "associate_public_ip_addresses" {
  description = "Whether or not to associate public IP addresses with ECS container instances."
  type        = string
  default     = false
  nullable    = false
}

variable "security_groups" {
  description = "The list of security group IDs to associate with the cluster."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "include_default_ingress_rule" {
  description = "Whether or not to include the default ingress rule on the ECS container instances security group."
  type        = string
  default     = true
  nullable    = false
}
variable "include_default_egress_rule" {
  description = "Whether or not to include the default egress rule on the ECS container instances security group."
  type        = string
  default     = true
  nullable    = false
}
variable "default_ingress_cidrs" {
  description = "The CIDRs allowed access to containers."
  type        = list(string)
  default     = ["10.0.0.0/8"]
  nullable    = false
}
variable "default_egress_cidrs" {
  description = "The CIDRs accessible from containers."
  type        = list(string)
  default     = ["0.0.0.0/0"]
  nullable    = false
}

variable "tags" {
  description = "Map of tags to be applied to all resources in cluster"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "enable_container_insights" {
  description = "Whether or not to enable container insights on the ECS cluster."
  type        = string
  default     = false
  nullable    = false
}

variable "protect_cluster_instances_from_scale_in" {
  description = "Whether or not to protect cluster instances in the autoscaling group from scale in."
  type        = string
  default     = false
  nullable    = false
}

variable "include_asg_capacity_provider" {
  description = "Whether or not to add the created ASG as a capacity provider for the ECS cluster."
  type        = string
  default     = false
  nullable    = false
}
variable "asg_capacity_provider_manage_termination_protection" {
  description = "Whether or not to allow ECS to manage termination protection for the ASG capacity provider."
  type        = string
  default     = true
  nullable    = false
}
variable "asg_capacity_provider_manage_scaling" {
  description = "Whether or not to allow ECS to manage scaling for the ASG capacity provider."
  type        = string
  default     = true
  nullable    = false
}
variable "asg_capacity_provider_minimum_scaling_step_size" {
  description = "The minimum scaling step size for ECS managed scaling of the ASG capacity provider."
  type        = number
  default     = 1
  nullable    = false
}
variable "asg_capacity_provider_maximum_scaling_step_size" {
  description = "The maximum scaling step size for ECS managed scaling of the ASG capacity provider."
  type        = number
  default     = 1000
  nullable    = false
}
variable "asg_capacity_provider_target_capacity" {
  description = "The target capacity, as a percentage from 1 to 100, for the ASG capacity provider."
  type        = number
  default     = 100
  nullable    = false
}

variable "cluster_log_group_retention" {
  description = "The number of days logs will be retained in the CloudWatch log group of the cluster"
  type        = number
  default     = 0
  nullable    = false
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring of EC2 instance(s)"
  type        = bool
  default     = true
  nullable    = false
}

variable "cluster_instance_enable_ebs_volume_encryption" {
  description = "Determines whether encryption is enabled on the EBS volume"
  type        = bool
  default     = true
  nullable    = false
}

variable "cluster_instance_ebs_volume_kms_key_id" {
  description = "KMS key to use for encryption of the EBS volume when enabled"
  type        = string
  default     = null
}
