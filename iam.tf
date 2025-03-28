locals {
  cluster_instance_policy_contents = coalesce(
    var.cluster_instance_iam_policy_contents,
    file("${path.module}/policies/cluster-instance-policy.json"))
}

resource "aws_iam_role" "cluster_instance_role" {
  count = var.include_cluster_instances ? 1 : 0

  description        = "cluster-instance-role-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  assume_role_policy = file("${path.module}/policies/cluster-instance-role.json")

  tags = local.tags
}

resource "aws_iam_policy" "cluster_instance_policy" {
  count = var.include_cluster_instances ? 1 : 0

  description = "cluster-instance-policy-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  policy      = local.cluster_instance_policy_contents
}

resource "aws_iam_policy_attachment" "cluster_instance_policy_attachment" {
  count = var.include_cluster_instances ? 1 : 0

  name       = "cluster-instance-policy-attachment-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  roles      = [aws_iam_role.cluster_instance_role[0].id]
  policy_arn = aws_iam_policy.cluster_instance_policy[0].arn
}

resource "aws_iam_instance_profile" "cluster" {
  count = var.include_cluster_instances ? 1 : 0

  name = "cluster-instance-profile-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  path = "/"
  role = aws_iam_role.cluster_instance_role[0].name
}

resource "aws_iam_role" "cluster_service_role" {
  description        = "cluster-service-role-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  assume_role_policy = file("${path.module}/policies/cluster-service-role.json")

  tags = local.tags
}

resource "aws_iam_policy" "cluster_service_policy" {
  description = "cluster-service-policy-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  policy      = coalesce(var.cluster_service_iam_policy_contents, file("${path.module}/policies/cluster-service-policy.json"))
}

resource "aws_iam_policy_attachment" "cluster_service_policy_attachment" {
  name       = "cluster-instance-policy-attachment-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  roles      = [aws_iam_role.cluster_service_role.id]
  policy_arn = aws_iam_policy.cluster_service_policy.arn
}

resource "null_resource" "iam_wait" {
  depends_on = [
    aws_iam_role.cluster_instance_role,
    aws_iam_policy.cluster_instance_policy,
    aws_iam_policy_attachment.cluster_instance_policy_attachment,
    aws_iam_instance_profile.cluster,
    aws_iam_role.cluster_service_role,
    aws_iam_policy.cluster_service_policy,
    aws_iam_policy_attachment.cluster_service_policy_attachment
  ]

  provisioner "local-exec" {
    command = "sleep 30"
  }
}
