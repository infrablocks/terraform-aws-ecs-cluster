require 'aws-sdk'
require 'awspec'

require_relative '../terraform_module'

shared_context :terraform do
  include Awspec::Helper::Finder

  let(:cloudwatch_logs_client) { Aws::CloudWatchLogs::Client.new }

  let(:vars) {TerraformModule.configuration.for(:harness).vars}

  let(:spec_vars) {Vars.load_from(Paths.from_project_root_directory('config', 'vars', 'spec.yml'), {})}

  def output_for(role, name)
    TerraformModule.output_for(role, name)
  end

  def reprovision(override_vars)
    TerraformModule.provision_for(
        :harness,
        TerraformModule.configuration.for(:harness)
            .vars.to_h.merge(override_vars))
  end
end