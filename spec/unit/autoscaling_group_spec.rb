# frozen_string_literal: true

require 'spec_helper'

describe 'autoscaling group' do
  describe 'by default' do
    let(:component) do
      var(role: :root, name: 'component')
    end
    let(:deployment_identifier) do
      var(role: :root, name: 'deployment_identifier')
    end
    let(:cluster_name) do
      var(role: :root, name: 'cluster_name')
    end
    let(:private_subnet_ids) do
      output(role: :prerequisites, name: 'private_subnet_ids')
    end

    before(:context) do
      @plan = plan(role: :root)
    end

    it 'creates a autoscaling group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_autoscaling_group')
              .once)
    end

    it 'uses a minimum cluster size of 1' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_autoscaling_group')
              .with_attribute_value(:min_size, 1))
    end

    it 'uses all private subnets' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_autoscaling_group')
              .with_attribute_value(
                :vpc_zone_identifier,
                containing_exactly(*private_subnet_ids)
              ))
    end

    describe 'tags' do
      it 'has Name' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_autoscaling_group')
                .with_attribute_value(
                  :tag,
                  including({
                              key: 'Name',
                              propagate_at_launch: true,
                              value: "cluster-worker-#{component}-" \
                                     "#{deployment_identifier}-default"
                            })
                ))
      end

      it 'has ClusterName' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_autoscaling_group')
                .with_attribute_value(
                  :tag,
                  including({
                              key: 'ClusterName',
                              propagate_at_launch: true,
                              value: 'default'
                            })
                ))
      end

      it 'has Component' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_autoscaling_group')
                .with_attribute_value(
                  :tag,
                  including({
                              key: 'Component',
                              propagate_at_launch: true,
                              value: component
                            })
                ))
      end

      it 'has DeploymentIdentifier' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_autoscaling_group')
                .with_attribute_value(
                  :tag,
                  including({
                              key: 'DeploymentIdentifier',
                              propagate_at_launch: true,
                              value: deployment_identifier
                            })
                ))
      end

      it 'has ImportantTag' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_autoscaling_group')
                .with_attribute_value(
                  :tag,
                  including({
                              key: 'ImportantTag',
                              propagate_at_launch: true,
                              value: 'important-value'
                            })
                ))
      end
    end
  end

  describe 'when cluster sizes provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.cluster_minimum_size = 2
        vars.cluster_maximum_size = 5
        vars.cluster_desired_capacity = 3
      end
    end

    it 'uses the provided minimum cluster size' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_autoscaling_group')
              .with_attribute_value(:min_size, 2))
    end

    it 'uses the provided maximum cluster size' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_autoscaling_group')
              .with_attribute_value(:max_size, 5))
    end

    it 'uses the provided desired cluster capacity' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_autoscaling_group')
              .with_attribute_value(:desired_capacity, 3))
    end
  end
end
