resource "null_resource" "iam_wait" {
  depends_on = [
    "aws_iam_role.cluster_instance_role",
    "aws_iam_policy.cluster_instance_policy",
    "aws_iam_policy_attachment.cluster_instance_policy_attachment",
    "aws_iam_instance_profile.cluster",
    "aws_iam_role.cluster_service_role",
    "aws_iam_policy.cluster_service_policy",
    "aws_iam_policy_attachment.cluster_service_policy_attachment"
  ]

  provisioner "local-exec" {
    command = "sleep 120"
  }
}

data "template_file" "cluster_user_data" {
  template = "${coalesce(var.cluster_instance_user_data_template, file("${path.module}/user-data/cluster.tpl"))}"

  vars {
    cluster_name = "${aws_ecs_cluster.cluster.name}"
  }
}

resource "aws_launch_configuration" "cluster" {
  name_prefix = "cluster-${var.component}-${var.deployment_identifier}-${var.cluster_name}-"
  image_id = "${lookup(var.cluster_instance_amis, var.region)}"
  instance_type = "${var.cluster_instance_type}"
  key_name = "${aws_key_pair.cluster.key_name}"

  iam_instance_profile = "${aws_iam_instance_profile.cluster.name}"

  user_data = "${data.template_file.cluster_user_data.rendered}"

  security_groups = [
    "${aws_security_group.cluster.id}"
  ]

  depends_on = [
    "null_resource.iam_wait"
  ]

  root_block_device {
    volume_size = "${var.cluster_instance_root_block_device_size}"
  }

  ebs_block_device {
    device_name = "${var.cluster_instance_docker_block_device_name}"
    volume_size = "${var.cluster_instance_docker_block_device_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "cluster" {
  name = "asg-${var.component}-${var.deployment_identifier}-${var.cluster_name}"

  vpc_zone_identifier = [
    "${split(",", var.private_subnet_ids)}"
  ]

  launch_configuration = "${aws_launch_configuration.cluster.name}"

  min_size = "${var.cluster_minimum_size}"
  max_size = "${var.cluster_maximum_size}"
  desired_capacity = "${var.cluster_desired_capacity}"

  tag {
    key = "Name"
    value = "cluster-worker-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
    propagate_at_launch = true
  }

  tag{
    key = "Component"
    value = "${var.component}"
    propagate_at_launch = true
  }

  tag {
    key = "DeploymentIdentifier"
    value = "${var.deployment_identifier}"
    propagate_at_launch = true
  }

  tag {
    key = "ClusterName"
    value = "${var.cluster_name}"
    propagate_at_launch = true
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.component}-${var.deployment_identifier}-${var.cluster_name}"

  depends_on = ["null_resource.iam_wait"]
}
