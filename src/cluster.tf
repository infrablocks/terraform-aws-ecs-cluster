resource "null_resource" "iam_wait" {
  depends_on = [
    "aws_iam_role.cluster_instance_role",
    "aws_iam_instance_profile.cluster"
  ]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

data "template_file" "cluster_user_data" {
  template = "${coalesce(var.user_data_template, file("${path.module}/scripts/user-data.tpl"))}"

  vars {
    cluster_name = "${var.cluster_name}"
  }
}

resource "aws_launch_configuration" "cluster" {
  name_prefix = "cluster-${var.component}-${var.deployment_identifier}-${var.cluster_name}-"
  image_id = "${lookup(var.amis, var.region)}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.cluster.key_name}"

  iam_instance_profile = "${aws_iam_instance_profile.cluster.name}"

  user_data = "${data.template_file.cluster_user_data.rendered}"

  security_groups = [
    "${aws_security_group.cluster.id}"
  ]

  depends_on = [
    "null_resource.iam_wait"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

//resource "aws_autoscaling_group" "cluster" {
//  name = "asg-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
//
//  vpc_zone_identifier = [
//    "${split(",", var.private_subnet_ids)}"
//  ]
//
//
//  min_size = "${var.minimum_size}"
//  max_size = "${var.maximum_size}"
//  desired_capacity = "${var.desired_capacity}"
//
//  tag {
//    key = "Name"
//    value = "cluster-worker-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
//    propagate_at_launch = true
//  }
//  tag {
//    key = "Component"
//    value = "${var.component}"
//    propagate_at_launch = true
//  }
//  tag {
//    key = "DeploymentIdentifier"
//    value = "${var.deployment_identifier}"
//    propagate_at_launch = true
//  }
//  tag {
//    key = "ClusterName"
//    value = "${var.cluster_name}"
//    propagate_at_launch = true
//  }
//
//  lifecycle {
//    create_before_destroy = true
//  }
//}
