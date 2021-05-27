module "base_network" {
  source  = "infrablocks/base-networking/aws"
  version = "4.0.0"

  vpc_cidr           = var.vpc_cidr
  region             = var.region
  availability_zones = var.availability_zones

  component             = var.component
  deployment_identifier = var.deployment_identifier

  private_zone_id = var.private_zone_id
}
