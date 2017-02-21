require 'aws-sdk'

shared_context :terraform do
  include Awspec::Helper::Finder
  
  let(:cloudwatch_logs_client) { Aws::CloudWatchLogs::Client.new } 
end