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
    command = "sleep 120"
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

data "template_file" "ami_id" {
  template = coalesce(lookup(var.cluster_instance_amis, var.region), data.aws_ami.amazon_linux_2.image_id)
}

data "template_file" "cluster_user_data" {
  template = coalesce(var.cluster_instance_user_data_template, file("${path.module}/user-data/cluster.tpl"))

  vars = {
    cluster_name = aws_ecs_cluster.cluster.name
  }
}

resource "aws_launch_configuration" "cluster" {
  name_prefix = "cluster-${var.component}-${var.deployment_identifier}-${var.cluster_name}-"
  image_id = data.template_file.ami_id.rendered
  instance_type = var.cluster_instance_type
  key_name = var.cluster_instance_ssh_public_key_path == "" ? "" : element(concat(aws_key_pair.cluster.*.key_name, list("")), 0)

  iam_instance_profile = aws_iam_instance_profile.cluster.name

  user_data = data.template_file.cluster_user_data.rendered

  security_groups = concat(list(aws_security_group.cluster.id), var.security_groups)

  associate_public_ip_address = var.associate_public_ip_addresses == "yes" ? true : false

  depends_on = [
    null_resource.iam_wait
  ]

  root_block_device {
    volume_size = var.cluster_instance_root_block_device_size
    volume_type = var.cluster_instance_root_block_device_type
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "cluster" {
  name_prefix = "asg-${var.component}-${var.deployment_identifier}-${var.cluster_name}-"

  vpc_zone_identifier = var.subnet_ids

  launch_configuration = aws_launch_configuration.cluster.name

  min_size = var.cluster_minimum_size
  max_size = var.cluster_maximum_size
  desired_capacity = var.cluster_desired_capacity

  tag {
    key = "Name"
    value = "cluster-worker-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key = "ClusterName"
    value = var.cluster_name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = local.tags
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.component}-${var.deployment_identifier}-${var.cluster_name}"

  depends_on = [null_resource.iam_wait]

  tags = local.tags
}
