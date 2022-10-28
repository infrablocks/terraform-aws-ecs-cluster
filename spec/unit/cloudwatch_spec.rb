# frozen_string_literal: true

require 'spec_helper'

describe 'CloudWatch' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:dep_id) do
    var(role: :root, name: 'deployment_identifier')
  end
  let(:log_group_name) do
    "/#{component}/#{dep_id}/ecs-cluster/default"
  end

  before(:context) do
    @plan = plan(role: :root)
  end

  describe 'logging' do
    it 'creates log group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_cloudwatch_log_group')
              .once)
    end

    it 'has log group name' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_cloudwatch_log_group')
              .with_attribute_value(:name, log_group_name))
    end
  end
end
