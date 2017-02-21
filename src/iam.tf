resource "aws_iam_role" "cluster_instance_role" {
  name = "cluster-instance-role-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  assume_role_policy = "${file("${path.module}/policies/cluster-instance-role.json")}"
}

resource "aws_iam_policy" "cluster_instance_policy" {
  name = "cluster-instance-policy-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  description = "cluster-instance-policy-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  policy = "${file("${path.module}/policies/cluster-instance-policy.json")}"
}

resource "aws_iam_policy_attachment" "cluster_instance_policy_attachment" {
  name = "cluster-instance-policy-attachment-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  roles = ["${aws_iam_role.cluster_instance_role.id}"]
  policy_arn = "${aws_iam_policy.cluster_instance_policy.arn}"
}

resource "aws_iam_instance_profile" "cluster" {
  name = "cluster-instance-profile-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  path = "/"
  roles = [
    "${aws_iam_role.cluster_instance_role.name}"
  ]
}

resource "aws_iam_role" "cluster_service_role" {
  name = "cluster-service-role-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  assume_role_policy = "${file("${path.module}/policies/cluster-service-role.json")}"
}

resource "aws_iam_policy" "cluster_service_policy" {
  name = "cluster-service-policy-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  description = "cluster-service-policy-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  policy = "${file("${path.module}/policies/cluster-service-policy.json")}"
}

resource "aws_iam_policy_attachment" "cluster_service_policy_attachment" {
  name = "cluster-instance-policy-attachment-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  roles = ["${aws_iam_role.cluster_service_role.id}"]
  policy_arn = "${aws_iam_policy.cluster_service_policy.arn}"
}
