resource "aws_iam_role" "cluster_instance_role" {
  description = "cluster-instance-role-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  assume_role_policy = file("${path.module}/policies/cluster-instance-role.json")

  tags = {
    Component = var.component
    DeploymentIdentifier = var.deployment_identifier
  }
}

data "template_file" "cluster_instance_policy" {
  template = file("${path.module}/policies/cluster-instance-policy.json")
}

resource "aws_iam_policy" "cluster_instance_policy" {
  description = "cluster-instance-policy-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  policy = coalesce(var.cluster_instance_iam_policy_contents, data.template_file.cluster_instance_policy.rendered)
}

resource "aws_iam_policy_attachment" "cluster_instance_policy_attachment" {
  name = "cluster-instance-policy-attachment-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  roles = [aws_iam_role.cluster_instance_role.id]
  policy_arn = aws_iam_policy.cluster_instance_policy.arn
}

resource "aws_iam_instance_profile" "cluster" {
  name = "cluster-instance-profile-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  path = "/"
  role = aws_iam_role.cluster_instance_role.name
}

resource "aws_iam_role" "cluster_service_role" {
  description = "cluster-service-role-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  assume_role_policy = file("${path.module}/policies/cluster-service-role.json")

  tags = {
    Component = var.component
    DeploymentIdentifier = var.deployment_identifier
  }
}

resource "aws_iam_policy" "cluster_service_policy" {
  description = "cluster-service-policy-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  policy = coalesce(var.cluster_service_iam_policy_contents, file("${path.module}/policies/cluster-service-policy.json"))
}

resource "aws_iam_policy_attachment" "cluster_service_policy_attachment" {
  name = "cluster-instance-policy-attachment-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
  roles = [aws_iam_role.cluster_service_role.id]
  policy_arn = aws_iam_policy.cluster_service_policy.arn
}
