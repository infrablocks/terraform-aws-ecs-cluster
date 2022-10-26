locals {
  base_tags = {
    Component            = var.component
    DeploymentIdentifier = var.deployment_identifier
  }

  tags = merge(local.received_tags, local.base_tags)
}
