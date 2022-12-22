# frozen_string_literal: true

require 'spec_helper'

describe 'Launch Configuration' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:dep_id) do
    var(role: :root, name: 'deployment_identifier')
  end
  let(:region) do
    var(role: :root, name: 'region')
  end

  before(:context) do
    @plan = plan(role: :root)
  end

  it 'does not exist' do
    expect(@plan)
      .not_to(include_resource_creation(type: 'aws_launch_configuration'))
  end
end
