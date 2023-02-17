data "aws_caller_identity" "current" {}

locals {
  base_tags = {
    Component            = var.component
    DeploymentIdentifier = var.deployment_identifier
  }

  tags = merge(var.tags, local.base_tags)

  cluster_instance_ebs_volume_kms_key_id = var.cluster_instance_ebs_volume_kms_key_id == null ? "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:alias/aws/ebs" : var.cluster_instance_ebs_volume_kms_key_id
}
