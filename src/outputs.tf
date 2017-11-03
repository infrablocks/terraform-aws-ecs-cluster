output "cluster_id" {
  value = "${aws_ecs_cluster.cluster.id}"
}

output "cluster_name" {
  value = "${aws_ecs_cluster.cluster.name}"
}

output "autoscaling_group_name" {
  value = "${aws_autoscaling_group.cluster.name}"
}

output "launch_configuration_name" {
  value = "${aws_launch_configuration.cluster.name}"
}

output "instance_role_arn" {
  value = "${aws_iam_role.cluster_instance_role.arn}"
}

output "instance_role_id" {
  value = "${aws_iam_role.cluster_instance_role.unique_id}"
}

output "instance_policy_arn" {
  value = "${aws_iam_policy.cluster_instance_policy.arn}"
}

output "instance_policy_id" {
  value = "${aws_iam_policy.cluster_instance_policy.id}"
}

output "service_role_arn" {
  value = "${aws_iam_role.cluster_service_role.arn}"
}

output "service_role_id" {
  value = "${aws_iam_role.cluster_service_role.unique_id}"
}

output "service_policy_arn" {
  value = "${aws_iam_policy.cluster_service_policy.arn}"
}

output "service_policy_id" {
  value = "${aws_iam_policy.cluster_service_policy.id}"
}

output "log_group" {
  value = "${aws_cloudwatch_log_group.cluster.name}"
}
