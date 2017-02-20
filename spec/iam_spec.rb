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
  end
end
