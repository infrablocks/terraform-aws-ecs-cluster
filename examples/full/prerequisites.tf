module "base_network" {
  source  = "infrablocks/base-networking/aws"
  version = "4.0.0"

  vpc_cidr           = var.vpc_cidr
  region             = var.region
  availability_zones = var.availability_zones

  component             = var.component
  deployment_identifier = var.deployment_identifier

  private_zone_id = module.dns-zones.private_zone_id
}

resource "aws_default_vpc" "default" {}

module "dns-zones" {
  source = "infrablocks/dns-zones/aws"
  version = "1.0.0"

  domain_name = "infrablocks-ecs-cluster-example.com"
  private_domain_name = "infrablocks-ecs-cluster-example.net"
  private_zone_vpc_id = aws_default_vpc.default.id
  private_zone_vpc_region = var.region
}

resource "aws_security_group" "custom_security_group" {
  count       = 2
  name        = "${var.component}-${var.deployment_identifier}-${count.index}"
  description = "Custom security group for component: ${var.component}, deployment: ${var.deployment_identifier}"
  vpc_id      = module.base_network.vpc_id

  tags = {
    Name                 = "${var.component}-${var.deployment_identifier}-${count.index}"
    Component            = var.component
    DeploymentIdentifier = var.deployment_identifier
  }
}
