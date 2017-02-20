require 'spec_helper'

describe 'ECS Cluster' do
  include_context :terraform

  let(:component) { RSpec.configuration.component }
  let(:deployment_identifier) { RSpec.configuration.deployment_identifier }
  let(:cluster_name) { RSpec.configuration.cluster_name }
  let(:instance_type) { RSpec.configuration.instance_type }
  let(:image_id) { RSpec.configuration.image_id }
  let(:private_network_cidr) { RSpec.configuration.private_network_cidr }

  let(:vpc_id) { Terraform.output(name: 'vpc_id') }
  let(:launch_configuration_name) { Terraform.output(name: 'launch_configuration_name') }

  context 'launch configuration' do
    subject {
      launch_configuration(launch_configuration_name)
    }

    it { should exist }
    its(:instance_type) { should eq(instance_type) }
    its(:image_id) { should eq(image_id) }

    its(:key_name) { should eq("cluster-#{component}-#{deployment_identifier}-#{cluster_name}") }

    its(:iam_instance_profile) do
      should eq("cluster-instance-profile-#{component}-#{deployment_identifier}-#{cluster_name}")
    end

    its(:user_data) do
      should eq(Base64.strict_encode64(<<~DOC))
        #!/bin/bash
        echo "ECS_CLUSTER=#{cluster_name}" > /etc/ecs/ecs.config
      DOC
    end

    it { should have_security_group("#{component}-#{deployment_identifier}-#{cluster_name}") }

    it 'has a name containing the component, deployment_identifier and cluster_name' do
      expect(launch_configuration_name).to(match(/#{component}/))
      expect(launch_configuration_name).to(match(/#{deployment_identifier}/))
      expect(launch_configuration_name).to(match(/#{cluster_name}/))
    end
  end

  context 'security group' do
    subject { security_group("#{component}-#{deployment_identifier}-#{cluster_name}") }

    it { should exist }
    it { should have_tag('Component').value(component) }
    it { should have_tag('DeploymentIdentifier').value(deployment_identifier) }
    its(:vpc_id) { should eq(vpc_id) }

    it 'allows inbound TCP connectivity on all ports from any address within the VPC' do
      expect(subject.inbound_rule_count).to(eq(1))

      ingress_rule = subject.ip_permissions.first

      expect(ingress_rule.from_port).to(eq(1))
      expect(ingress_rule.to_port).to(eq(65535))
      expect(ingress_rule.ip_protocol).to(eq('tcp'))
      expect(ingress_rule.ip_ranges.map(&:cidr_ip)).to(eq([private_network_cidr]))
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
end
