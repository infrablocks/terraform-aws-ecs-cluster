
resource "aws_security_group" "custom_sg" {
  count = 2
  name = "${var.component}-${var.deployment_identifier}-${count.index}"
  description = "Custom security group for component: ${var.component}, deployment: ${var.deployment_identifier}"
  vpc_id = "${module.base_network.vpc_id}"

  tags = {
    Name = "${var.component}-${var.deployment_identifier}-${count.index}"
    Component = "${var.component}"
    DeploymentIdentifier = "${var.deployment_identifier}"
  }
}
