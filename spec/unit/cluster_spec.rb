# frozen_string_literal: true

require 'spec_helper'

describe 'ECS Cluster' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:dep_id) do
    var(role: :root, name: 'deployment_identifier')
  end
  let(:execute_command_logging_path) do
    [:configuration, 0, :execute_command_configuration, 0, :logging]
  end

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

  context 'when execute command logging is disabled (default)' do
    it 'does not override execute command logging on the cluster' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_ecs_cluster')
              .with_attribute_value(execute_command_logging_path, 'OVERRIDE'))
    end

    it 'does not create a KMS key for execute command logging' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_kms_key'))
    end
  end

  context 'when execute command logging is enabled' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.enable_execute_command_logging = true
      end
    end

    it 'overrides execute command logging on the cluster' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_cluster')
              .with_attribute_value(execute_command_logging_path, 'OVERRIDE'))
    end

    it 'creates a KMS key for execute command logging' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_kms_key').once)
    end

    it 'has the expected KMS key description' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_kms_key')
              .with_attribute_value(
                :description,
                "#{component}-#{dep_id}-ecs-cluster-default-exec-kms-key"
              ))
    end

    it 'points execute command logging at the execute command log group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_cluster')
              .with_attribute_value(
                [
                  :configuration, 0, :execute_command_configuration, 0,
                  :log_configuration, 0, :cloud_watch_log_group_name
                ],
                "/#{component}/#{dep_id}/ecs-cluster/default/exec"
              ))
    end

    it 'enables cloudwatch encryption for execute command logging by default' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_cluster')
              .with_attribute_value(
                [
                  :configuration, 0, :execute_command_configuration, 0,
                  :log_configuration, 0, :cloud_watch_encryption_enabled
                ],
                true
              ))
    end

    context 'with cloudwatch encryption disabled' do
      before(:context) do
        @plan = plan(role: :root) do |vars|
          vars.enable_execute_command_logging = true
          vars.enable_execute_command_cloudwatch_encryption = false
        end
      end

      it 'disables cloudwatch encryption for execute command logging' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_ecs_cluster')
                .with_attribute_value(
                  [
                    :configuration, 0, :execute_command_configuration, 0,
                    :log_configuration, 0, :cloud_watch_encryption_enabled
                  ],
                  false
                ))
      end
    end
  end
end
