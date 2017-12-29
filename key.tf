resource "aws_key_pair" "cluster" {
  key_name = "cluster-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  public_key = "${file(var.cluster_instance_ssh_public_key_path)}"
}
