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
        expect(capacity_provider # integration
            .auto_scaling_group_provider
            .auto_scaling_group_arn)
          .to(eq(output_for(:harness, 'autoscaling_group_arn')))
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end
end
