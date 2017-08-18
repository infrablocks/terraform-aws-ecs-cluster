require 'spec_helper'

describe 'CloudWatch' do
  let(:log_group){
    log_group_name =
        "/#{vars.component}/#{vars.deployment_identifier}/ecs-cluster/#{vars.cluster_name}"

    cloudwatch_logs_client
        .describe_log_groups({log_group_name_prefix: log_group_name})
        .log_groups
        .first
  }

  context 'logging' do
    it 'creates log group' do
      expect(log_group).to_not be_nil
    end
  end

  context 'outputs' do
    it 'outputs the log group name' do
      expect(output_with_name('log_group')).to(eq(log_group.log_group_name))
    end
  end
end
