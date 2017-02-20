resource "aws_iam_role" "cluster_instance_role" {
  name = "cluster-instance-role-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  assume_role_policy = "${file("${path.module}/policies/cluster-instance-role.json")}"
}

resource "aws_iam_instance_profile" "cluster" {
  name = "cluster-instance-profile-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  path = "/"
  roles = [
    "${aws_iam_role.cluster_instance_role.name}"
  ]
}