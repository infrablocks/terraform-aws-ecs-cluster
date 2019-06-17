output "vpc_id" {
  value = "${module.base_network.vpc_id}"
}

output "vpc_cidr" {
  value = "${module.base_network.vpc_cidr}"
}

output "private_subnet_ids" {
  value = "${module.base_network.private_subnet_ids}"
}

output "security_group_ids" {
  value = "${join(",", aws_security_group.custom_sg.*.id)}"
}
