# frozen_string_literal: true

require 'spec_helper'

describe 'ASG Capacity Provider' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:dep_id) do
    var(role: :root, name: 'deployment_identifier')
  end

  before(:context) do
    @plan = plan(role: :root)
  end

  context 'when include_asg_capacity_provider is true and\
   include_cluster_instances is true' do
    describe 'by default' do
      before(:context) do
        @plan = plan(role: :root) do |vars|
          vars.include_asg_capacity_provider = true
          vars.include_cluster_instances = true
        end
      end

      # rubocop:disable RSpec/MultipleExpectations
      it 'attaches the ASG as a capacity provider for the ECS cluster' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_capacity_provider')
                .once)

        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_capacity_provider')
                .with_attribute_value(
                  :name, "cp-#{component}-#{dep_id}-default"
                ))
      end
      # rubocop:enable RSpec/MultipleExpectations

      it 'includes the AmazonECSManaged tag on the ASG' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_autoscaling_group')
                .with_attribute_value(
                  :tag,
                  including({
                              key: 'AmazonECSManaged',
                              propagate_at_launch: true,
                              value: ''
                            })
                ))
      end
    end

    context 'with managed termination protection' do
      before(:context) do
        @plan = plan(role: :root) do |vars|
          vars.include_cluster_instances = true
          vars.include_asg_capacity_provider = true
          vars.asg_capacity_provider_manage_termination_protection = true
        end
      end

      it 'enables managed termination protection' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_capacity_provider')
                .with_attribute_value(
                  [
                    :auto_scaling_group_provider,
                    0,
                    :managed_termination_protection
                  ],
                  'ENABLED'
                ))
      end
    end

    context 'without managed termination protection' do
      before(:context) do
        @plan = plan(role: :root) do |vars|
          vars.include_cluster_instances = true
          vars.include_asg_capacity_provider = true
          vars.asg_capacity_provider_manage_termination_protection = false
        end
      end

      it 'disables managed termination protection' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_capacity_provider')
                .with_attribute_value(
                  [
                    :auto_scaling_group_provider,
                    0,
                    :managed_termination_protection
                  ],
                  'DISABLED'
                ))
      end
    end

    context 'with managed scaling' do
      before(:context) do
        @plan = plan(role: :root) do |vars|
          vars.include_cluster_instances = true
          vars.include_asg_capacity_provider = true
          vars.asg_capacity_provider_manage_scaling = true
          vars.asg_capacity_provider_minimum_scaling_step_size = 3
          vars.asg_capacity_provider_maximum_scaling_step_size = 300
          vars.asg_capacity_provider_target_capacity = 90
        end
      end

      it 'enables managed scaling' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_capacity_provider')
                .with_attribute_value(
                  [
                    :auto_scaling_group_provider,
                    0,
                    :managed_scaling,
                    0,
                    :status
                  ],
                  'ENABLED'
                ))
      end

      it 'uses the provided minimum scaling step size' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_capacity_provider')
                .with_attribute_value(
                  [
                    :auto_scaling_group_provider,
                    0,
                    :managed_scaling,
                    0,
                    :minimum_scaling_step_size
                  ],
                  3
                ))
      end

      it 'uses the provided maximum scaling step size' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_capacity_provider')
                .with_attribute_value(
                  [
                    :auto_scaling_group_provider,
                    0,
                    :managed_scaling,
                    0,
                    :maximum_scaling_step_size
                  ],
                  300
                ))
      end

      it 'uses the provided target capacity' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_capacity_provider')
                .with_attribute_value(
                  [
                    :auto_scaling_group_provider,
                    0,
                    :managed_scaling,
                    0,
                    :target_capacity
                  ],
                  90
                ))
      end
    end

    context 'without managed scaling' do
      before(:context) do
        @plan = plan(role: :root) do |vars|
          vars.include_cluster_instances = true
          vars.include_asg_capacity_provider = true
          vars.asg_capacity_provider_manage_scaling = false
        end
      end

      it 'disables managed scaling' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_capacity_provider')
                .with_attribute_value(
                  [
                    :auto_scaling_group_provider,
                    0,
                    :managed_scaling,
                    0,
                    :status
                  ],
                  'DISABLED'
                ))
      end
    end
  end

  context 'when include_asg_capacity_provider is false \
  and include_cluster_instances is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_cluster_instances = true
        vars.include_asg_capacity_provider = false
      end
    end

    it 'does not create a capacity provider for the ECS cluster' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_ecs_capacity_provider'))
    end

    it 'does not include the AmazonECSManaged tag on the ASG' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_autoscaling_group')
              .with_attribute_value(
                :tag,
                including({
                            key: 'AmazonECSManaged',
                            propagate_at_launch: true,
                            value: ''
                          })
              ))
    end
  end

  context 'when include_asg_capacity_provider is true and include_cluster_instances is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_cluster_instances = false
        vars.include_asg_capacity_provider = true
      end
    end

    it 'does not create a capacity provider for the ECS cluster' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_ecs_capacity_provider'))
    end

    it 'does not include the AmazonECSManaged tag on the ASG' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_autoscaling_group')
                  .with_attribute_value(
                    :tag,
                    including({
                                key: 'AmazonECSManaged',
                                propagate_at_launch: true,
                                value: ''
                              })
                  ))
    end
  end

  context 'when include_asg_capacity_provider is false and include_cluster_instances is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_cluster_instances = false
        vars.include_asg_capacity_provider = false
      end
    end

    it 'does not create a capacity provider for the ECS cluster' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_ecs_capacity_provider'))
    end

    it 'does not include the AmazonECSManaged tag on the ASG' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_autoscaling_group')
                  .with_attribute_value(
                    :tag,
                    including({
                                key: 'AmazonECSManaged',
                                propagate_at_launch: true,
                                value: ''
                              })
                  ))
    end
  end

  context 'when additional_capacity_providers are provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.cluster_name = 'special-cluster'
        vars.include_cluster_instances = false
        vars.include_asg_capacity_provider = false
        vars.additional_capacity_providers = ['FARGATE']
      end
    end

    it 'creates a cluster capacity providers resource' do
      expect(@plan)
        .to(include_resource_creation(
          type: 'aws_ecs_cluster_capacity_providers'
        )
              .once)
    end

    it 'uses the correct cluster name on the cluster capacity providers resource' do
      expect(@plan)
        .to(include_resource_creation(
          type: 'aws_ecs_cluster_capacity_providers'
        )
              .with_attribute_value(
                :cluster_name,
                "#{component}-#{dep_id}-special-cluster"
              ))
    end

    it 'adds the additional capacity providers to the cluster capacity providers' do
      expect(@plan)
        .to(include_resource_creation(
          type: 'aws_ecs_cluster_capacity_providers'
        )
              .with_attribute_value(
                :capacity_providers, ['FARGATE']
              ))
    end
  end
end
