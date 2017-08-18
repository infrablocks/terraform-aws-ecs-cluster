require 'aws-sdk'
require 'awspec'

require_relative '../terraform_module'

shared_context :terraform do
  include Awspec::Helper::Finder

  let(:cloudwatch_logs_client) { Aws::CloudWatchLogs::Client.new }

  let(:vars) { TerraformModule.configuration.vars}

  def output_with_name(name)
    TerraformModule.output_with_name(name)
  end
end