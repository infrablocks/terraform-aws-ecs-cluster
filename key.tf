resource "aws_key_pair" "cluster" {
  count      = local.cluster_instance_ssh_public_key_path == "" ? 0 : 1
  key_name   = "cluster-${var.component}-${var.deployment_identifier}-${local.cluster_name}"
  public_key = file(local.cluster_instance_ssh_public_key_path)
}
