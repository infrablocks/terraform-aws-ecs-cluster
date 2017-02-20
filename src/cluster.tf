resource "aws_launch_configuration" "cluster" {
  name_prefix = "cluster-${var.component}-${var.deployment_identifier}-${var.cluster_name}-"
  image_id = "${lookup(var.amis, var.region)}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.cluster.key_name}"

  security_groups = [
    "${aws_security_group.cluster.id}"
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
