require 'spec_helper'
require 'json'

describe 'IAM policies, profiles and roles' do
  include_context :terraform

  let(:component) { RSpec.configuration.component }
  let(:deployment_identifier) { RSpec.configuration.deployment_identifier }
  let(:cluster_name) { RSpec.configuration.cluster_name }

  context 'cluster instance profile' do
    # TODO: Work out how to test this
  end

  context 'cluster instance role' do
    subject {
      iam_role("cluster-instance-role-#{component}-#{deployment_identifier}-#{cluster_name}")
    }

    it { should exist }
    it 'allows assuming a role of ec2' do
      policy_document = JSON.parse(URI.decode(subject.assume_role_policy_document))
      expect(policy_document["Statement"].count).to(eq(1))

      policy_document_statement = policy_document["Statement"].first

      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Action']).to(eq('sts:AssumeRole'))
      expect(policy_document_statement['Principal']['Service']).to(eq('ec2.amazonaws.com'))
    end

    it {
      should have_iam_policy("cluster-instance-policy-#{component}-#{deployment_identifier}-#{cluster_name}")
    }
  end

  context 'cluster instance policy' do
    subject {
      iam_policy("cluster-instance-policy-#{component}-#{deployment_identifier}-#{cluster_name}")
    }

    let(:policy_document) do
      policy_version_response = iam_client.get_policy_version({
          policy_arn: subject.arn,
          version_id: subject.default_version_id,
      })

      JSON.parse(URI.decode(
          policy_version_response.policy_version.document))
    end

    it { should exist }

    it 'allows ECS actions' do
      expect(policy_document["Statement"].count).to(eq(1))

      policy_document_statement = policy_document["Statement"].first
      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Resource']).to(eq('*'))
      expect(policy_document_statement['Action']).to(include('ecs:CreateCluster'))
      expect(policy_document_statement['Action']).to(include('ecs:RegisterContainerInstance'))
      expect(policy_document_statement['Action']).to(include('ecs:DeregisterContainerInstance'))
      expect(policy_document_statement['Action']).to(include('ecs:DiscoverPollEndpoint'))
      expect(policy_document_statement['Action']).to(include('ecs:Poll'))
      expect(policy_document_statement['Action']).to(include('ecs:StartTelemetrySession'))
      expect(policy_document_statement['Action']).to(include('ecs:Submit*'))
    end

    it 'allows log creation' do
      expect(policy_document["Statement"].count).to(eq(1))

      policy_document_statement = policy_document["Statement"].first
      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Resource']).to(eq('*'))
      expect(policy_document_statement['Action']).to(include('logs:CreateLogStream'))
      expect(policy_document_statement['Action']).to(include('logs:PutLogEvents'))
    end
  end
end
