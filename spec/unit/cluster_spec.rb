# frozen_string_literal: true

require 'spec_helper'

describe 'ECS Cluster' do
  before(:context) do
    @plan = plan(role: :root)
  end

  it 'exists' do
    expect(@plan)
      .to(include_resource_creation(type: 'aws_ecs_cluster')
            .once)
  end

  context 'when container insights enabled' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.enable_container_insights = 'yes'
      end
    end

    it 'has container insights enabled on the cluster' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_cluster')
              .with_attribute_value([:setting, 0, :value], 'enabled'))
    end
  end

  context 'when container insights disabled' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.enable_container_insights = 'no'
      end
    end

    it 'has container insights disabled on the cluster' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_cluster')
              .with_attribute_value([:setting, 0, :value], 'disabled'))
    end
  end
end
