resource "null_resource" "iam_wait" {
  depends_on = [
    aws_iam_role.cluster_instance_role,
    aws_iam_policy.cluster_instance_policy,
    aws_iam_policy_attachment.cluster_instance_policy_attachment,
    aws_iam_instance_profile.cluster,
    aws_iam_role.cluster_service_role,
    aws_iam_policy.cluster_service_policy,
    aws_iam_policy_attachment.cluster_service_policy_attachment,
  ]

  provisioner "local-exec" {
    command = "sleep 120"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

data "template_file" "cluster_user_data" {
  template = coalesce(
    var.cluster_instance_user_data_template,
    file("${path.module}/user-data/cluster.tpl"),
  )

  vars = {
    cluster_name = aws_ecs_cluster.cluster.name
  }
}

resource "aws_launch_configuration" "cluster" {
  name_prefix = "cluster-${var.component}-${var.deployment_identifier}-${var.cluster_name}-"
  image_id = coalesce(
    var.cluster_instance_amis[var.region],
    data.aws_ami.amazon_linux.image_id,
  )
  instance_type = var.cluster_instance_type
  key_name      = aws_key_pair.cluster.key_name

  iam_instance_profile = aws_iam_instance_profile.cluster.name

  user_data = data.template_file.cluster_user_data.rendered

  security_groups = [
    aws_security_group.cluster.id,
  ]

  associate_public_ip_address = var.associate_public_ip_addresses == "yes" ? true : false

  depends_on = [null_resource.iam_wait]

  root_block_device {
    volume_size = var.cluster_instance_root_block_device_size
  }

  ebs_block_device {
    device_name = var.cluster_instance_docker_block_device_name
    volume_size = var.cluster_instance_docker_block_device_size
    encrypted = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudformation_stack" "cluster" {
  name = replace(
    "asg-${var.component}-${var.deployment_identifier}-${var.cluster_name}",
    "/[^-a-zA-Z0-9]/",
    "-",
  )
  template_body = <<EOF
---
AWSTemplateFormatVersion: "2010-09-09"
Description: Terraform-managed CF Stack for Auto-Scaling Group
Resources:
  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      AutoScalingGroupName: asg-${var.component}-${var.deployment_identifier}-${var.cluster_name}
      VPCZoneIdentifier: ${jsonencode(split(",", var.subnet_ids))}
      LaunchConfigurationName: ${aws_launch_configuration.cluster.name}
      MinSize: ${var.cluster_minimum_size}
      MaxSize: ${var.cluster_maximum_size}
      TargetGroupARNs: ${jsonencode(var.cluster_target_group_arns)}
      Tags:
        - Key: Name
          Value: cluster-worker-${var.component}-${var.deployment_identifier}-${var.cluster_name}
          PropagateAtLaunch: True
        - Key: Component
          Value: ${var.component}
          PropagateAtLaunch: True
        - Key: DeploymentIdentifier
          Value: ${var.deployment_identifier}
          PropagateAtLaunch: True
        - Key: ClusterName
          Value: ${var.cluster_name}
          PropagateAtLaunch: True
    UpdatePolicy:
      AutoScalingRollingUpdate:
        MaxBatchSize: ${var.cluster_rolling_update_maximum_batch_size}
        MinInstancesInService: ${var.cluster_rolling_update_min_instances_in_service}
        SuspendProcesses:
          - HealthCheck
          - ReplaceUnhealthy
          - AZRebalance
          - AlarmNotification
          - ScheduledActions
Outputs:
  AutoScalingGroupName:
    Description: The name of the Auto-Scaling Group
    Value: !Ref AutoScalingGroup
EOF

}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.component}-${var.deployment_identifier}-${var.cluster_name}"

  depends_on = [null_resource.iam_wait]
}

