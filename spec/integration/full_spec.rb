# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
describe 'full example' do
  before(:context) do
    # security_group_ids =
    #   output(role: :full, name: 'custom_security_group_ids')

    apply(role: :full) do |vars|
      # vars.security_groups = "[\"#{security_group_ids.join('","')}\"]"
      vars.include_asg_capacity_provider = 'yes'
    end
  end

  after(:context) do
    destroy(
      role: :full,
      only_if: -> { !ENV['FORCE_DESTROY'].nil? || ENV['SEED'].nil? }
    )
  end

  let(:component) do
    var(role: :full, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :full, name: 'deployment_identifier')
  end
  let(:cluster_name) do
    output(role: :full, name: 'cluster_name')
  end
  let(:autoscaling_group_name) do
    output(role: :full, name: 'autoscaling_group_name')
  end
  let(:autoscaling_group_arn) do
    output(role: :full, name: 'autoscaling_group_arn')
  end
  let(:launch_configuration_name) do
    output(role: :full, name: 'launch_configuration_name')
  end
  let(:log_group) do
    output(role: :full, name: 'log_group')
  end
  let(:instance_role_id) do
    output(role: :full, name: 'instance_role_id')
  end
  let(:instance_role_arn) do
    output(role: :full, name: 'instance_role_arn')
  end
  let(:instance_policy_id) do
    output(role: :full, name: 'instance_policy_id')
  end
  let(:instance_policy_arn) do
    output(role: :full, name: 'instance_policy_arn')
  end
  let(:service_role_id) do
    output(role: :full, name: 'service_role_id')
  end
  let(:service_role_arn) do
    output(role: :full, name: 'service_role_arn')
  end
  let(:service_policy_id) do
    output(role: :full, name: 'service_policy_id')
  end
  let(:service_policy_arn) do
    output(role: :full, name: 'service_policy_arn')
  end

  describe 'Autoscaling Group' do
    subject(:auto_scaling_group) do
      autoscaling_group(autoscaling_group_name)
    end

    it { is_expected.to exist }

    its(:launch_configuration_name) do
      is_expected.to eq(launch_configuration_name)
    end
  end

  describe 'ASG Capacity Provider' do # TODO: it can't find cap providers
    context 'when capacity provider included' do
      let(:asg) do
        autoscaling_group(output_for(:harness, 'autoscaling_group_name'))
      end
      let(:capacity_providers) do
        ecs_client = Aws::ECS::Client.new(region: 'eu-west-2')

        ecs_cluster(cluster_name)
          .capacity_providers
          .map do |cp|
          ecs_client
            .describe_capacity_providers(capacity_providers: [cp])
            .capacity_providers[0]
        end
      end

      # rubocop:disable RSpec/MultipleExpectations
      it 'attaches the ASG as a capacity provider for the ECS cluster' do
        expect(capacity_providers.length).to(eq(1))

        capacity_provider = capacity_providers.first

        expect(capacity_provider
                 .auto_scaling_group_provider
                 .auto_scaling_group_arn)
          .to(eq(autoscaling_group_arn))
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end

  describe 'CloudWatch' do
    let(:cloudwatch_log_group) do
      log_group_name =
        "/#{component}/#{deployment_identifier}/ecs-cluster/services" # TODO

      cloudwatch_logs_client =
        Aws::CloudWatchLogs::Client.new(region: 'eu-west-2')
      cloudwatch_logs_client
        .describe_log_groups({ log_group_name_prefix: log_group_name })
        .log_groups
        .first
    end

    describe 'outputs' do
      it 'outputs the log group name' do
        expect(log_group).to(eq(cloudwatch_log_group.log_group_name))
      end
    end
  end

  describe 'IAM policies, profiles and roles' do
    describe 'cluster instance profile' do
      subject(:instance_profile) do
        instance_profile_name =
          "cluster-instance-profile-#{cluster_name}"

        iam_client = Aws::IAM::Client.new(region: 'eu-west-2')
        iam_client
          .get_instance_profile({ instance_profile_name: })
          .instance_profile
      end

      it 'has the cluster instance role' do
        expect(instance_profile.roles.first.role_name)
          .to(eq(iam_role(instance_role_id).name))
      end
    end

    describe 'cluster instance role' do
      subject(:role) do
        iam_role(instance_role_id)
      end

      it {
        expect(role).to have_iam_policy(instance_policy_id)
      }
    end

    describe 'outputs' do
      let(:cluster_instance_iam_role) do
        iam_role(instance_role_id)
      end
      let(:cluster_service_iam_role) do
        iam_role(service_role_id)
      end
      let(:cluster_instance_iam_policy) do
        iam_policy(instance_policy_id)
      end
      let(:cluster_service_iam_policy) do
        iam_policy(service_policy_id)
      end

      it 'outputs instance role arn' do
        expect(instance_role_arn).to(eq(cluster_instance_iam_role.arn))
      end

      it 'outputs instance role id' do
        expect(instance_role_id).to(eq(cluster_instance_iam_role.role_id))
      end

      it 'outputs instance policy arn' do
        expect(instance_policy_arn).to(eq(cluster_instance_iam_policy.arn))
      end

      it 'outputs service role arn' do
        expect(service_role_arn).to(eq(cluster_service_iam_role.arn))
      end

      it 'outputs service role id' do
        expect(service_role_id).to(eq(cluster_service_iam_role.role_id))
      end

      it 'outputs service policy arn' do
        expect(service_policy_arn).to(eq(cluster_service_iam_policy.arn))
      end
    end
  end

  describe 'Launch Configuration' do
    subject(:launch_config) do
      launch_configuration(launch_configuration_name)
    end

    it 'does not add a docker block device' do # TODO: does this test do anything?
      expect(launch_config.block_device_mappings.size).to(eq(1))
    end

    # context 'when custom security groups are provided' do
    #   it {
    #     expect(launch_config).to have_security_group(
    #       "#{component}-#{deployment_identifier}-0"
    #     )
    #   }
    #
    #   it {
    #     expect(launch_config).to have_security_group(
    #       "#{component}-#{deployment_identifier}-1"
    #     )
    #   }
    #
    #   it 'has correct number of security groups' do
    #     expect(launch_config.security_groups.size).to(eq(3))
    #   end
    # end

    its(:key_name) do
      puts launch_config
      is_expected.to eq("cluster-#{cluster_name}")
    end

    its(:user_data) do
      is_expected.to eq(Base64.strict_encode64(<<~DOC))
        #!/bin/bash
        echo "ECS_CLUSTER=#{cluster_name}" > /etc/ecs/ecs.config
      DOC
    end

    it {
      expect(launch_config).to have_security_group(cluster_name)
    }

    describe 'launch config name' do
      it 'contains the component' do
        expect(launch_configuration_name).to(match(/#{component}/))
      end

      it 'contains the deployment identifier' do
        expect(launch_configuration_name)
          .to(match(/#{deployment_identifier}/))
      end

      it 'contains the cluster name' do
        expect(launch_configuration_name).to(match(/#{cluster_name}/))
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
