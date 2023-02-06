locals {
  ami_id = coalesce(
    lookup(local.cluster_instance_amis, var.region),
    data.aws_ami.amazon_linux_2.image_id)
  cluster_user_data_template = coalesce(
    local.cluster_instance_user_data_template,
    file("${path.module}/user-data/cluster.tpl"))
  cluster_user_data = replace(
    local.cluster_user_data_template,
    "$${cluster_name}", local.cluster_full_name)
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_launch_template" "cluster" {
  name_prefix          = "cluster-${var.component}-${var.deployment_identifier}-${local.cluster_name}-"
  image_id             = local.ami_id
  instance_type        = local.cluster_instance_type
  key_name             = local.cluster_instance_ssh_public_key_path == "" ? "" : element(concat(aws_key_pair.cluster.*.key_name, [""]), 0)

  iam_instance_profile {
    name = aws_iam_instance_profile.cluster.name
  }

  user_data = base64encode(local.cluster_user_data)

  network_interfaces {
    associate_public_ip_address = local.associate_public_ip_addresses == "yes" ? true : false
    security_groups = concat([aws_security_group.cluster.id], local.security_groups)
  }

  block_device_mappings {
    device_name = var.cluster_instance_root_block_device_path

    ebs {
      volume_size = local.cluster_instance_root_block_device_size
      volume_type = local.cluster_instance_root_block_device_type
    }
  }

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  depends_on = [
    null_resource.iam_wait
  ]
}

resource "aws_autoscaling_group" "cluster" {
  name_prefix = "asg-${var.component}-${var.deployment_identifier}-${local.cluster_name}-"

  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.cluster.id
    version = "$Latest"
  }

  min_size         = local.cluster_minimum_size
  max_size         = local.cluster_maximum_size
  desired_capacity = local.cluster_desired_capacity

  protect_from_scale_in = ((local.include_asg_capacity_provider == "yes" && local.asg_capacity_provider_manage_termination_protection == "yes") || local.protect_cluster_instances_from_scale_in == "yes")

  tag {
    key                 = "Name"
    value               = "cluster-worker-${var.component}-${var.deployment_identifier}-${local.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "ClusterName"
    value               = local.cluster_name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = local.include_asg_capacity_provider == "yes" ? merge({
      AmazonECSManaged : ""
    }, local.tags) : local.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
