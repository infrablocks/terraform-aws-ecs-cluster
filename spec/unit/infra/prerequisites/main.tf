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

module "dns-zones" {
  source = "infrablocks/dns-zones/aws"
  version = "1.0.0"

  domain_name = "infrablocks-ecs-cluster-example.com"
  private_domain_name = "infrablocks-ecs-cluster-example.net"
  private_zone_vpc_id = var.private_zone_vpc_id
  private_zone_vpc_region = var.region
}
