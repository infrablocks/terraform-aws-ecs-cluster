# frozen_string_literal: true

require 'spec_helper'

describe 'ASG Capacity Provider' do
  subject { ecs_cluster("#{component}-#{dep_id}-#{cluster_name}") }

  include_context 'terraform'

  let(:component) { vars.component }
  let(:asg) do
    autoscaling_group(output_for(:harness, 'autoscaling_group_name'))
  end
  let(:capacity_providers) do
    subject
      .capacity_providers
      .map do |cp|
      ecs_client
        .describe_capacity_providers(capacity_providers: [cp])
        .capacity_providers[0]
    end
  end
  let(:dep_id) { vars.deployment_identifier }
  let(:cluster_name) { vars.cluster_name }

  context 'when capacity provider not included' do
    before(:all) do
      reprovision(include_asg_capacity_provider: 'no')
    end

    it 'does not create a capacity provider for the ECS cluster' do
      expect(capacity_providers.length).to(eq(0))
    end

    it 'does not include the AmazonECSManaged tag on the ASG' do
      expect(asg
          .tags
          .filter { |tag| tag.key == 'AmazonECSManaged' }
          .length)
        .to(eq(0))
    end
  end

  context 'when capacity provider included' do
    describe 'by default' do
      before(:all) do
        reprovision(include_asg_capacity_provider: 'yes')
      end

      after(:all) do
        # It's not very nice needing to destroy here but it seems the capacity
        # provider resource is missing some dependencies internally and can't
        # cope with changing attributes
        destroy(include_asg_capacity_provider: 'yes')
      end

      # rubocop:disable RSpec/MultipleExpectations
      it 'attaches the ASG as a capacity provider for the ECS cluster' do
        expect(capacity_providers.length).to(eq(1))

        capacity_provider = capacity_providers.first

        expect(capacity_provider.name)
          .to(eq("cp-#{component}-#{dep_id}-#{cluster_name}"))
        expect(capacity_provider
            .auto_scaling_group_provider
            .auto_scaling_group_arn)
          .to(eq(output_for(:harness, 'autoscaling_group_arn')))
      end
      # rubocop:enable RSpec/MultipleExpectations

      it 'includes the AmazonECSManaged tag on the ASG' do
        expect(asg
            .tags
            .filter { |tag| tag.key == 'AmazonECSManaged' }
            .length)
          .to(eq(1))
      end
    end

    context 'with managed termination protection' do
      before(:all) do
        reprovision(
          include_asg_capacity_provider: 'yes',
          asg_capacity_provider_manage_termination_protection: 'yes'
        )
      end

      after(:all) do
        # In order to destroy, the instances need their termination protection
        # removed first
        autoscaling_group_name =
          output_for(:harness, 'autoscaling_group_name')
        instance_ids = autoscaling_client
                       .describe_auto_scaling_groups(
                         {
                           auto_scaling_group_names: [autoscaling_group_name]
                         }
                       )
                       .auto_scaling_groups
                       .first
                       .instances
                       .map(&:instance_id)
        autoscaling_client
          .set_instance_protection(
            {
              auto_scaling_group_name: autoscaling_group_name,
              instance_ids:,
              protected_from_scale_in: false
            }
          )
        destroy(
          include_asg_capacity_provider: 'yes',
          asg_capacity_provider_manage_termination_protection: 'yes'
        )
      end

      it 'enables managed termination protection' do
        capacity_provider = capacity_providers.first

        expect(capacity_provider
            .auto_scaling_group_provider
            .managed_termination_protection)
          .to(eq('ENABLED'))
      end
    end

    context 'without managed termination protection' do
      before(:all) do
        reprovision(
          include_asg_capacity_provider: 'yes',
          asg_capacity_provider_manage_termination_protection: 'no'
        )
      end

      after(:all) do
        destroy(
          include_asg_capacity_provider: 'yes',
          asg_capacity_provider_manage_termination_protection: 'no'
        )
      end

      it 'disables managed termination protection' do
        capacity_provider = capacity_providers.first

        expect(capacity_provider
            .auto_scaling_group_provider
            .managed_termination_protection)
          .to(eq('DISABLED'))
      end
    end

    context 'with managed scaling' do
      before(:all) do
        reprovision(
          include_asg_capacity_provider: 'yes',
          asg_capacity_provider_manage_scaling: 'yes',
          asg_capacity_provider_minimum_scaling_step_size: 3,
          asg_capacity_provider_maximum_scaling_step_size: 300,
          asg_capacity_provider_target_capacity: 90
        )
      end

      after(:all) do
        destroy(
          include_asg_capacity_provider: 'yes',
          asg_capacity_provider_manage_scaling: 'yes',
          asg_capacity_provider_minimum_scaling_step_size: 3,
          asg_capacity_provider_maximum_scaling_step_size: 300,
          asg_capacity_provider_target_capacity: 90
        )
      end

      it 'enables managed scaling' do
        capacity_provider = capacity_providers.first

        expect(capacity_provider
            .auto_scaling_group_provider
            .managed_scaling
            .status)
          .to(eq('ENABLED'))
      end

      it 'uses the provided minimum scaling step size' do
        capacity_provider = capacity_providers.first

        expect(capacity_provider
            .auto_scaling_group_provider
            .managed_scaling
            .minimum_scaling_step_size)
          .to(eq(3))
      end

      it 'uses the provided maximum scaling step size' do
        capacity_provider = capacity_providers.first

        expect(capacity_provider
            .auto_scaling_group_provider
            .managed_scaling
            .maximum_scaling_step_size)
          .to(eq(300))
      end

      it 'uses the provided target capacity' do
        capacity_provider = capacity_providers.first

        expect(capacity_provider
            .auto_scaling_group_provider
            .managed_scaling
            .target_capacity)
          .to(eq(90))
      end
    end

    context 'without managed scaling' do
      before(:all) do
        reprovision(
          include_asg_capacity_provider: 'yes',
          asg_capacity_provider_manage_scaling: 'no'
        )
      end

      after(:all) do
        destroy(
          include_asg_capacity_provider: 'yes',
          asg_capacity_provider_manage_scaling: 'no'
        )
      end

      it 'disables managed scaling' do
        capacity_provider = capacity_providers.first

        expect(capacity_provider
            .auto_scaling_group_provider
            .managed_scaling
            .status)
          .to(eq('DISABLED'))
      end
    end
  end
end
