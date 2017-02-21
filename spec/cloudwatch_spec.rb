require 'spec_helper'

describe 'CloudWatch' do
  include_context :terraform

  let(:component) { RSpec.configuration.component }
  let(:deployment_identifier) { RSpec.configuration.deployment_identifier }
  let(:cluster_name) { RSpec.configuration.cluster_name }

  let(:log_group){
    cloudwatch_logs_client.describe_log_groups({
        log_group_name_prefix: "/#{component}/#{deployment_identifier}/ecs-cluster/#{cluster_name}"
    }).log_groups.first
  }

  context 'logging' do
    it 'creates log group' do
      expect(log_group).to_not be_nil
    end
  end

  context 'outputs' do
    it 'outputs the log group name' do
      expect(Terraform.output(name: 'log_group')).to(eq(log_group.log_group_name))
    end
  end
end
