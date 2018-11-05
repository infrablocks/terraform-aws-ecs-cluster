output "cluster_id" {
  description = "The ID of the created ECS cluster."
  value = "${aws_ecs_cluster.cluster.id}"
}

output "cluster_name" {
  description = "The name of the created ECS cluster."
  value = "${aws_ecs_cluster.cluster.name}"
}

output "autoscaling_group_name" {
  description = "The name of the autoscaling group for the ECS container instances."
  value = "${aws_autoscaling_group.cluster.name}"
}

output "launch_configuration_name" {
  description = "The name of the launch configuration for the ECS container instances."
  value = "${data.template_file.ami_id.rendered == data.aws_ami.amazon_linux_1.image_id ?
    element(concat(aws_launch_configuration.cluster_with_docker_volume.*.name, list("")), 0) :
    element(concat(aws_launch_configuration.cluster_without_docker_volume.*.name, list("")), 0)}"
}

output "security_group_id" {
  description = "The ID of the security group associated with the ECS container instances."
  value = "${aws_security_group.cluster.id}"
}

output "instance_role_arn" {
  description = "The ARN of the container instance role."
  value = "${aws_iam_role.cluster_instance_role.arn}"
}

output "instance_role_id" {
  description = "The ID of the container instance role."
  value = "${aws_iam_role.cluster_instance_role.unique_id}"
}

output "instance_policy_arn" {
  description = "The ARN of the container instance policy."
  value = "${aws_iam_policy.cluster_instance_policy.arn}"
}

output "instance_policy_id" {
  description = "The ID of the container instance policy."
  value = "${aws_iam_policy.cluster_instance_policy.id}"
}

output "service_role_arn" {
  description = "The ARN of the ECS service role."
  value = "${aws_iam_role.cluster_service_role.arn}"
}

output "service_role_id" {
  description = "The ID of the ECS service role."
  value = "${aws_iam_role.cluster_service_role.unique_id}"
}

output "service_policy_arn" {
  description = "The ARN of the ECS service policy."
  value = "${aws_iam_policy.cluster_service_policy.arn}"
}

output "service_policy_id" {
  description = "The ID of the ECS service policy."
  value = "${aws_iam_policy.cluster_service_policy.id}"
}

output "log_group" {
  description = "The name of the default log group for the cluster."
  value = "${aws_cloudwatch_log_group.cluster.name}"
}
