require 'spec_helper'

describe 'ECS Cluster' do
  include_context :terraform

  context 'launch configuration' do
    subject {
      launch_configuration(output_for(:harness, 'launch_configuration_name'))
    }

    it {should exist}
    its(:instance_type) {should eq(vars.cluster_instance_type)}

    context 'uses latest amazon linux 2 optimised for ECS' do
      let(:latest_amazon_linux_2_ecs_optimised_ami_id) {
        response = ec2_client.describe_images(
            {
                owners: ['amazon'],
                filters: [
                    {
                        name: 'name',
                        values: ['amzn2-ami-ecs-hvm-*-x86_64-ebs']
                    }
                ]
            })
        most_recent_image = response.images.max_by do |image|
          DateTime.parse(image.creation_date)
        end

        most_recent_image.image_id
      }

      its(:image_id) do
        should eq(latest_amazon_linux_2_ecs_optimised_ami_id)
      end
    end

    it 'does not add a docker block device' do
      expect(subject.block_device_mappings.size).to(eq(1))
    end

    context 'when custom security groups are provided' do
      before(:all) do
        security_group_ids =
            output_for(:prerequisites, 'security_group_ids', parse: true)
        reprovision(
            security_groups:
                '["' + security_group_ids.join('","') + '"]'
        )
      end

      it {should have_security_group("#{vars.component}-#{vars.deployment_identifier}-0")}
      it {should have_security_group("#{vars.component}-#{vars.deployment_identifier}-1")}

      it 'should have correct number of security groups' do
        expect(subject.security_groups.size).to(eq(3))
      end
    end

    context 'when AMIs specified' do
      it 'uses provided image ID' do
        ami_id = configuration.for(:harness).ami_id_in_region
        puts ami_id
        reprovision(
            cluster_instance_amis:
                '{' + vars.region + '="' + ami_id + '"}')

        expect(
            launch_configuration(
                output_for(:harness, 'launch_configuration_name'))
                .image_id).to eq(ami_id)
      end
    end

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

    it {should have_security_group("#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}")}

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
  end

  context 'security group' do
    subject {security_group("#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}")}

    it {should exist}
    it {should have_tag('Component').value(vars.component)}
    it {should have_tag('DeploymentIdentifier').value(vars.deployment_identifier)}
    its(:vpc_id) {should eq(output_for(:prerequisites, 'vpc_id'))}

    it 'outputs the security group ID' do
      expect(output_for(:harness, 'security_group_id')).to(eq(subject.id))
    end

    context 'when default ingress and egress are included' do
      it 'allows inbound TCP connectivity on all ports from any address within the VPC' do
        expect(subject.inbound_rule_count).to(eq(1))

        ingress_rule = subject.ip_permissions.first

        expect(ingress_rule.from_port).to(eq(1))
        expect(ingress_rule.to_port).to(eq(65535))
        expect(ingress_rule.ip_protocol).to(eq('tcp'))
        expect(ingress_rule.ip_ranges.map(&:cidr_ip)).to(eq(vars.allowed_cidrs))
      end

      it 'allows outbound TCP connectivity on all ports and protocols anywhere' do
        expect(subject.outbound_rule_count).to(be(1))

        egress_rule = subject.ip_permissions_egress.first

        expect(egress_rule.from_port).to(be_nil)
        expect(egress_rule.to_port).to(be_nil)
        expect(egress_rule.ip_protocol).to(eq('-1'))
        expect(egress_rule.ip_ranges.map(&:cidr_ip)).to(eq(vars.egress_cidrs))
      end
    end

    context 'when default ingress and egress are not included' do
      before(:all) do
        reprovision(
            include_default_ingress_rule: 'no',
            include_default_egress_rule: 'no')
      end

      it 'has no ingress or egress rules' do
        expect(subject.inbound_rule_count).to(eq(0))
        expect(subject.outbound_rule_count).to(eq(0))
      end
    end
  end

  context 'autoscaling group' do
    subject {autoscaling_group(output_for(:harness, 'autoscaling_group_name'))}

    it {should exist}
    its(:min_size) {should eq(vars.cluster_minimum_size)}
    its(:max_size) {should eq(vars.cluster_maximum_size)}
    its(:launch_configuration_name) do
      should eq(output_for(:harness, 'launch_configuration_name'))
    end
    its(:desired_capacity) {should eq(vars.cluster_desired_capacity)}

    it 'uses all private subnets' do
      expect(subject.vpc_zone_identifier.split(','))
          .to(contain_exactly(
              *output_for(:prerequisites, 'private_subnet_ids', parse: true)))
    end

    it {should have_tag('Name').value("cluster-worker-#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}")}
    it {should have_tag('Component').value(vars.component)}
    it {should have_tag('DeploymentIdentifier').value(vars.deployment_identifier)}
    it {should have_tag('ClusterName').value(vars.cluster_name)}
  end

  context 'cluster' do
    subject {ecs_cluster("#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}")}

    it {should exist}
  end

  context 'outputs' do
    let(:cluster) {ecs_cluster("#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}")}
    let(:asg) {autoscaling_group(output_for(:harness, 'autoscaling_group_name'))}

    it 'outputs the cluster id' do
      expect(output_for(:harness, 'cluster_id'))
          .to(eq(cluster.cluster_arn))
    end

    it 'outputs the cluster name' do
      expect(output_for(:harness, 'cluster_name'))
          .to(eq(cluster.cluster_name))
    end

    it 'outputs the autoscaling group name' do
      # Seems to be redundant after autoscaling group name changed to be autogenerated
      expect(output_for(:harness, 'autoscaling_group_name'))
          .to(eq(asg.auto_scaling_group_name))
    end
  end
end
