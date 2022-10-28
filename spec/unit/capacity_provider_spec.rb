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

  context 'when capacity provider included' do
    describe 'by default' do
      before(:context) do
        @plan = plan(role: :root) do |vars|
          vars.include_asg_capacity_provider = 'yes'
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
          vars.include_asg_capacity_provider = 'yes'
          vars.asg_capacity_provider_manage_termination_protection = 'yes'
        end
      end

      it 'enables managed termination protection' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_capacity_provider')
                .with_attribute_value(
                  :auto_scaling_group_provider,
                  including(
                    including(managed_termination_protection: 'ENABLED')
                  )
                ))
      end
    end

    context 'without managed termination protection' do
      before(:context) do
        @plan = plan(role: :root) do |vars|
          vars.include_asg_capacity_provider = 'yes'
          vars.asg_capacity_provider_manage_termination_protection = 'no'
        end
      end

      it 'disables managed termination protection' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_capacity_provider')
                .with_attribute_value(
                  :auto_scaling_group_provider,
                  including(
                    including(managed_termination_protection: 'DISABLED')
                  )
                ))
      end
    end

    context 'with managed scaling' do
      before(:context) do
        @plan = plan(role: :root) do |vars|
          vars.include_asg_capacity_provider = 'yes'
          vars.asg_capacity_provider_manage_scaling = 'yes'
          vars.asg_capacity_provider_minimum_scaling_step_size = 3
          vars.asg_capacity_provider_maximum_scaling_step_size = 300
          vars.asg_capacity_provider_target_capacity = 90
        end
      end

      it 'enables managed scaling' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_capacity_provider')
                .with_attribute_value(
                  :auto_scaling_group_provider,
                  including(including(
                              managed_scaling:
                                including(including(status: 'ENABLED'))
                            ))
                ))
      end

      it 'uses the provided minimum scaling step size' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_capacity_provider')
                .with_attribute_value(
                  :auto_scaling_group_provider,
                  including(including(
                              managed_scaling:
                                including(
                                  including(
                                    minimum_scaling_step_size: 3
                                  )
                                )
                            ))
                ))
      end

      it 'uses the provided maximum scaling step size' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_capacity_provider')
                .with_attribute_value(
                  :auto_scaling_group_provider,
                  including(including(
                              managed_scaling:
                                including(
                                  including(
                                    maximum_scaling_step_size: 300
                                  )
                                )
                            ))
                ))
      end

      it 'uses the provided target capacity' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_capacity_provider')
                .with_attribute_value(
                  :auto_scaling_group_provider,
                  including(including(
                              managed_scaling:
                                including(
                                  including(
                                    target_capacity: 90
                                  )
                                )
                            ))
                ))
      end
    end

    context 'without managed scaling' do
      before(:context) do
        @plan = plan(role: :root) do |vars|
          vars.include_asg_capacity_provider = 'yes'
          vars.asg_capacity_provider_manage_scaling = 'no'
        end
      end

      it 'disables managed scaling' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_capacity_provider')
                .with_attribute_value(
                  :auto_scaling_group_provider,
                  including(including(
                              managed_scaling:
                                including(including(status: 'DISABLED'))
                            ))
                ))
      end
    end
  end

  context 'when capacity provider not included' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_asg_capacity_provider = 'no'
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
end
