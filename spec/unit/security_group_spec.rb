# frozen_string_literal: true

require 'spec_helper'

describe 'Security Group' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:dep_id) do
    var(role: :root, name: 'deployment_identifier')
  end
  let(:vpc_id) do
    output(role: :prerequisites, name: 'vpc_id')
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root)
    end

    it 'exists' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .once)
    end

    describe 'tags' do
      it 'has Component' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_security_group')
                .with_attribute_value(
                  :tags,
                  including({ Component: component })
                ))
      end

      it 'has DeploymentIdentifier' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_security_group')
                .with_attribute_value(
                  :tags,
                  including({ DeploymentIdentifier: dep_id })
                ))
      end

      it 'has ImportantTag' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_security_group')
                .with_attribute_value(
                  :tags,
                  including({ ImportantTag: 'important-value' })
                ))
      end
    end

    it 'uses given vpc_id' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .with_attribute_value(:vpc_id, vpc_id))
    end

    context 'when default ingress and egress are included' do
      it('allows inbound TCP and UDP connectivity on all ports from any ' \
         'address within the VPC') do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_security_group_rule',
            name: 'cluster_default_ingress'
          )
                .with_attribute_value(:from_port, 0)
                .with_attribute_value(:to_port, 0)
                .with_attribute_value(:protocol, '-1')
                .with_attribute_value(:cidr_blocks, ['10.0.0.0/8']))
      end

      it 'allows outbound TCP connectivity on all ports and protocols anywhere' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_security_group_rule',
            name: 'cluster_default_egress'
          )
                .with_attribute_value(:from_port, 0)
                .with_attribute_value(:to_port, 0)
                .with_attribute_value(:protocol, '-1')
                .with_attribute_value(:cidr_blocks, ['0.0.0.0/0']))
      end
    end
  end

  describe 'when default ingress and egress are not included' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_default_ingress_rule = false
        vars.include_default_egress_rule = false
      end
    end

    it 'has no ingress rules' do
      expect(@plan)
        .not_to(include_resource_creation(
                  type: 'aws_security_group_rule',
                  name: 'cluster_default_ingress'
                ))
    end

    it 'has no egress rules' do
      expect(@plan)
        .not_to(include_resource_creation(
                  type: 'aws_security_group_rule',
                  name: 'cluster_default_egress'
                ))
    end
  end

  describe 'when include_cluster_instances is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_cluster_instances = false
      end
    end

    it 'does not create an aws_security_group' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group'))
    end

    it 'does not create any aws_security_group_rules' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group_rule'))
    end
  end

  describe 'when include_cluster_instances is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_cluster_instances = true
      end
    end

    it 'creates an aws_security_group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .once)
    end

    it 'creates aws_security_group_rules' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule'))
    end
  end
end
