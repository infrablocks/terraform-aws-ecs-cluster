require 'spec_helper'

describe 'CloudWatch' do
  include_context :terraform

  let(:component) { RSpec.configuration.component }
  let(:deployment_identifier) { RSpec.configuration.deployment_identifier }
  let(:cluster_name) { RSpec.configuration.cluster_name }

  context 'logging' do
    subject {
      response = cloudwatch_logs_client.describe_log_groups({
          log_group_name_prefix: "/#{component}/#{deployment_identifier}/ecs-cluster/#{cluster_name}"
      })
      response.log_groups.first
    }

    it { should_not be_nil }
  end
end
