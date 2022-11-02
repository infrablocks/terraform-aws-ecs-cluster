# frozen_string_literal: true

require 'spec_helper'
require 'json'

describe 'IAM policies, profiles and roles' do
  include_context 'terraform'

  describe 'cluster instance profile' do
    subject(:instance_profile) do
      instance_profile_name =
        "cluster-instance-profile-#{vars.component}-" \
        "#{vars.deployment_identifier}-#{vars.cluster_name}"

      iam_client
        .get_instance_profile({ instance_profile_name: })
        .instance_profile
    end

    it 'has the cluster instance role' do # integration
      expect(instance_profile.roles.first.role_name)
        .to(eq(iam_role(output_for(:harness, 'instance_role_id')).name))
    end
  end

  describe 'cluster instance role' do
    subject(:role) do
      iam_role(output_for(:harness, 'instance_role_id'))
    end

    it { # integration
      expect(role).to have_iam_policy(output_for(:harness,
                                                 'instance_policy_id'))
    }
  end

  describe 'outputs' do # integration, necessary?
    let(:cluster_instance_role) do
      iam_role(output_for(:harness, 'instance_role_id'))
    end
    let(:cluster_service_role) do
      iam_role(output_for(:harness, 'service_role_id'))
    end
    let(:cluster_instance_policy) do
      iam_policy(output_for(:harness, 'instance_policy_id'))
    end
    let(:cluster_service_policy) do
      iam_policy(output_for(:harness, 'service_policy_id'))
    end

    it 'outputs instance role arn' do
      expect(output_for(:harness, 'instance_role_arn'))
        .to(eq(cluster_instance_role.arn))
    end

    it 'outputs instance role id' do
      expect(output_for(:harness, 'instance_role_id'))
        .to(eq(cluster_instance_role.role_id))
    end

    it 'outputs instance policy arn' do
      expect(output_for(:harness, 'instance_policy_arn'))
        .to(eq(cluster_instance_policy.arn))
    end

    it 'outputs service role arn' do
      expect(output_for(:harness, 'service_role_arn'))
        .to(eq(cluster_service_role.arn))
    end

    it 'outputs service role id' do
      expect(output_for(:harness, 'service_role_id'))
        .to(eq(cluster_service_role.role_id))
    end

    it 'outputs service policy arn' do
      expect(output_for(:harness, 'service_policy_arn'))
        .to(eq(cluster_service_policy.arn))
    end
  end
end
