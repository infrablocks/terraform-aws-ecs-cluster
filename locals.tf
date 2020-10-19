locals {
  base_tags = {
    Component            = var.component
    DeploymentIdentifier = var.deployment_identifier
  }

  tags = merge(var.tags, local.base_tags)
}