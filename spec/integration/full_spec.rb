# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
describe 'full example' do
  before(:context) do
    apply(role: :full)
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
  let(:launch_template_name) do
    output(role: :full, name: 'launch_template_name')
  end
  let(:launch_template_id) do
    output(role: :full, name: 'launch_template_id')
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

    it 'has an associated launch template' do
      expect(auto_scaling_group.launch_template.launch_template_name)
        .to(eq(launch_template_name))
    end
  end

  describe 'ASG Capacity Provider' do
    context 'when capacity provider included' do
      let(:asg) do
        autoscaling_group(
          output_for(:harness, 'autoscaling_group_name')
        )
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
        "/#{component}/#{deployment_identifier}/ecs-cluster/services"

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

  describe 'Launch Template' do
    let(:created_launch_template) do
      launch_template(launch_template_name)
    end

    let(:created_launch_template_version) do
      created_launch_template.launch_template_version
    end
    let(:created_launch_template_data) do
      created_launch_template_version.launch_template_data
    end

    let(:security_group_ids) do
      created_launch_template_data.network_interfaces[0].groups
    end

    it 'has id of launch_template_id output' do
      expect(created_launch_template.launch_template_id)
        .to(eq(launch_template_id))
    end

    describe 'launch template name' do
      it 'contains the component' do
        expect(launch_template_name).to(match(/#{component}/))
      end

      it 'contains the deployment identifier' do
        expect(launch_template_name)
          .to(match(/#{deployment_identifier}/))
      end

      it 'contains the cluster name' do
        expect(launch_template_name).to(match(/#{cluster_name}/))
      end
    end

    it 'does not add a docker block device' do
      expect(created_launch_template_data.block_device_mappings.size)
        .to(eq(1))
    end

    it 'has correct number of security groups' do
      expect(security_group_ids.size).to(eq(3))
    end

    it 'includes the custom security groups' do
      custom_security_group_ids =
        output(role: :full, name: 'custom_security_group_ids')
      expect(security_group_ids)
        .to(include(*custom_security_group_ids))
    end

    it 'includes the default security group' do
      security_group_id = output(role: :full, name: 'security_group_id')
      expect(security_group_ids).to(include(security_group_id))
    end

    it 'configures the ECS cluster in the user data script' do
      expect(created_launch_template_data.user_data)
        .to(
          eq(Base64.strict_encode64(<<~DOC))
            #!/bin/bash
            echo "ECS_CLUSTER=#{cluster_name}" > /etc/ecs/ecs.config
          DOC
        )
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
