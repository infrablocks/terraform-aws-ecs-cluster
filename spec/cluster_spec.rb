require 'spec_helper'

describe 'ECS Cluster' do
  include_context :terraform

  context 'launch configuration' do
    subject {
      launch_configuration(output_for(:harness, 'launch_configuration_name'))
    }

    it { should exist }
    its(:instance_type) { should eq(vars.cluster_instance_type) }
    its(:image_id) { should eq(vars.cluster_instance_ami) }

    its(:key_name) do
      should eq("cluster-#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}")
    end

    its(:iam_instance_profile) do
      should eq("cluster-instance-profile-#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}")
    end

    its(:user_data) do
      should eq(Base64.strict_encode64(<<~DOC))
        #!/bin/bash
        echo "ECS_CLUSTER=#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}" > /etc/ecs/ecs.config
      DOC
    end

    it { should have_security_group("#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}") }

    it 'has a name containing the component, deployment_identifier and cluster_name' do
      launch_configuration_name = output_for(:harness, 'launch_configuration_name')

      expect(launch_configuration_name).to(match(/#{vars.component}/))
      expect(launch_configuration_name).to(match(/#{vars.deployment_identifier}/))
      expect(launch_configuration_name).to(match(/#{vars.cluster_name}/))
    end

    it 'uses the specified size for the root block device' do
      root_device_mapping = subject.block_device_mappings.find do |d|
        d.device_name != '/dev/xvdcz'
      end
      expect(root_device_mapping.ebs.volume_size)
          .to(eq(vars.cluster_instance_root_block_device_size))
    end

    it 'uses the specified size and name for the docker block device' do
      docker_device_mapping = subject.block_device_mappings.find do |d|
        d.device_name == '/dev/xvdcz'
      end
      expect(docker_device_mapping.device_name)
          .to(eq('/dev/xvdcz'))
      expect(docker_device_mapping.ebs.volume_size)
          .to(eq(vars.cluster_instance_docker_block_device_size))
    end
  end

  context 'security group' do
    subject { security_group("#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}") }

    it { should exist }
    it { should have_tag('Component').value(vars.component) }
    it { should have_tag('DeploymentIdentifier').value(vars.deployment_identifier) }
    its(:vpc_id) { should eq(output_for(:prerequisites, 'vpc_id')) }

    it 'allows inbound TCP connectivity on all ports from any address within the VPC' do
      expect(subject.inbound_rule_count).to(eq(1))

      ingress_rule = subject.ip_permissions.first

      expect(ingress_rule.from_port).to(eq(1))
      expect(ingress_rule.to_port).to(eq(65535))
      expect(ingress_rule.ip_protocol).to(eq('tcp'))
      expect(ingress_rule.ip_ranges.map(&:cidr_ip)).to(eq([vars.private_network_cidr]))
    end

    it 'allows outbound TCP connectivity on all ports and protocols anywhere' do
      expect(subject.outbound_rule_count).to(be(1))

      egress_rule = subject.ip_permissions_egress.first

      expect(egress_rule.from_port).to(be_nil)
      expect(egress_rule.to_port).to(be_nil)
      expect(egress_rule.ip_protocol).to(eq('-1'))
      expect(egress_rule.ip_ranges.map(&:cidr_ip)).to(eq(['0.0.0.0/0']))
    end
  end

  context 'autoscaling group' do
    subject { autoscaling_group("asg-#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}") }

    it { should exist }
    its(:min_size) { should eq(vars.cluster_minimum_size) }
    its(:max_size) { should eq(vars.cluster_maximum_size) }
    its(:launch_configuration_name) do
      should eq(output_for(:harness, 'launch_configuration_name'))
    end
    its(:desired_capacity) { should eq(vars.cluster_desired_capacity) }

    it 'uses all private subnets' do
      expect(subject.vpc_zone_identifier.split(','))
          .to(contain_exactly(*output_for(:prerequisites, 'private_subnet_ids').split(',')))
    end

    it { should have_tag('Name').value("cluster-worker-#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}")}
    it { should have_tag('Component').value(vars.component) }
    it { should have_tag('DeploymentIdentifier').value(vars.deployment_identifier) }
    it { should have_tag('ClusterName').value(vars.cluster_name) }
  end

  context 'cluster' do
    subject { ecs_cluster("#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}") }

    it { should exist }
  end

  context 'outputs' do
    let(:cluster) { ecs_cluster("#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}") }
    let(:asg) { autoscaling_group("asg-#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}") }

    it 'outputs the cluster id' do
      expect(output_for(:harness, 'cluster_id'))
          .to(eq(cluster.cluster_arn))
    end

    it 'outputs the cluster name' do
      expect(output_for(:harness, 'cluster_name'))
          .to(eq(cluster.cluster_name))
    end

    it 'outputs the autoscaling group name' do
      expect(output_for(:harness, 'autoscaling_group_name'))
          .to(eq(asg.auto_scaling_group_name))
    end
  end
end
