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

  it 'has container insights disabled by default' do
    expect(@plan)
      .to(include_resource_creation(type: 'aws_ecs_cluster')
            .with_attribute_value([:setting, 0, :value], 'disabled'))
  end

  context 'when container insights enabled' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.enable_container_insights = true
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
        vars.enable_container_insights = false
      end
    end

    it 'has container insights disabled on the cluster' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_cluster')
              .with_attribute_value([:setting, 0, :value], 'disabled'))
    end
  end

  %w[enhanced enabled disabled].each do |mode|
    context "when container insights mode is #{mode}" do
      before(:context) do
        @plan = plan(role: :root) do |vars|
          vars.container_insights_mode = mode
        end
      end

      it "sets container insights mode to #{mode}" do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_cluster')
                .with_attribute_value([:setting, 0, :value], mode))
      end
    end
  end

  context 'when container insights mode and legacy input are both set' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.enable_container_insights = true
        vars.container_insights_mode = 'disabled'
      end
    end

    it 'uses the explicit container insights mode' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_cluster')
              .with_attribute_value([:setting, 0, :value], 'disabled'))
    end
  end

  context 'when container insights mode is invalid' do
    it 'rejects the mode' do
      expect do
        plan(role: :root) do |vars|
          vars.container_insights_mode = 'invalid'
        end
      end.to raise_error(
        RubyTerraform::Errors::ExecutionError,
        /container_insights_mode must be one of/
      )
    end
  end
end
