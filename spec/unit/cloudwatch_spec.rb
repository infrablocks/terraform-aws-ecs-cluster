# # frozen_string_literal: true
#
# require 'spec_helper'
#
# describe 'CloudWatch' do
#   let(:log_group)  do
#     log_group_name =
#       "/#{vars.component}/#{vars.deployment_identifier}" \
#       "/ecs-cluster/#{vars.cluster_name}"
#
#     cloudwatch_logs_client
#       .describe_log_groups({ log_group_name_prefix: log_group_name })
#       .log_groups
#       .first
#   end
#
#   before(:all) do
#     reprovision
#   end
#
#   describe 'logging' do
#     it 'creates log group' do
#       expect(log_group).not_to be_nil
#     end
#   end
#
#   describe 'outputs' do
#     it 'outputs the log group name' do
#       expect(output_for(:harness, 'log_group'))
#         .to(eq(log_group.log_group_name))
#     end
#   end
# end
