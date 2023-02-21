locals {
  ami_id = coalesce(
    var.cluster_instance_ami,
    data.aws_ami.amazon_linux_2.image_id)
  cluster_user_data_template = coalesce(
    var.cluster_instance_user_data_template,
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
  name_prefix          = "cluster-${var.component}-${var.deployment_identifier}-${var.cluster_name}-"
  image_id             = local.ami_id
  instance_type        = var.cluster_instance_type
  key_name             = var.cluster_instance_ssh_public_key_path == null ? "" : element(concat(aws_key_pair.cluster.*.key_name, [""]), 0)

  iam_instance_profile {
    name = aws_iam_instance_profile.cluster.name
  }

  user_data = base64encode(local.cluster_user_data)

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_addresses
    security_groups = concat([aws_security_group.cluster.id], var.security_groups)
  }

  block_device_mappings {
    device_name = var.cluster_instance_root_block_device_path

    ebs {
      encrypted   = var.cluster_instance_enable_ebs_volume_encryption
      kms_key_id   = local.cluster_instance_ebs_volume_kms_key_id

      volume_size = var.cluster_instance_root_block_device_size
      volume_type = var.cluster_instance_root_block_device_type
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
  name_prefix = "asg-${var.component}-${var.deployment_identifier}-${var.cluster_name}-"

  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.cluster.id
    version = "$Latest"
  }

  min_size         = var.cluster_minimum_size
  max_size         = var.cluster_maximum_size
  desired_capacity = var.cluster_desired_capacity

  protect_from_scale_in = ((var.include_asg_capacity_provider && var.asg_capacity_provider_manage_termination_protection) || var.protect_cluster_instances_from_scale_in)

  tag {
    key                 = "Name"
    value               = "cluster-worker-${var.component}-${var.deployment_identifier}-${var.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "ClusterName"
    value               = var.cluster_name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.include_asg_capacity_provider ? merge({
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
