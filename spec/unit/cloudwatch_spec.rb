# frozen_string_literal: true

require 'spec_helper'

describe 'CloudWatch' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:dep_id) do
    var(role: :root, name: 'deployment_identifier')
  end
  let(:region) do
    var(role: :root, name: 'region')
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

    it 'uses log retention default of 0' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_cloudwatch_log_group')
              .with_attribute_value(:retention_in_days, 0))
    end

    context 'when cluster log group retention is set' do
      cluster_log_group_retention = 3

      before(:context) do
        @plan = plan(role: :root) do |vars|
          vars.cluster_log_group_retention = cluster_log_group_retention
        end
      end

      it 'uses provided log group retention' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_cloudwatch_log_group')
                .with_attribute_value(
                  :retention_in_days,
                  cluster_log_group_retention
                ))
      end
    end
  end

  describe 'execute command logging' do
    let(:execute_command_log_group_name) do
      "#{log_group_name}/exec"
    end

    context 'when no vars are overridden' do
      it 'does not create an execute command log group' do
        expect(@plan)
          .not_to(include_resource_creation(
                    type: 'aws_cloudwatch_log_group',
                    name: 'execute_command'
                  ))
      end

      it 'does not create a KMS key' do
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

      it 'creates an execute command log group' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_cloudwatch_log_group',
            name: 'execute_command'
          ).once)
      end

      it 'has the expected log group name' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_cloudwatch_log_group',
            name: 'execute_command'
          ).with_attribute_value(:name, execute_command_log_group_name))
      end

      it 'uses log retention default of 0' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_cloudwatch_log_group',
            name: 'execute_command'
          ).with_attribute_value(:retention_in_days, 0))
      end

      it 'grants CloudWatch Logs use of the key for this log group' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_kms_key')
                .with_attribute_value(
                  :policy,
                  include("log-group:#{execute_command_log_group_name}")
                ))
      end

      it 'scopes the key grant to the CloudWatch Logs service' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_kms_key')
                .with_attribute_value(
                  :policy,
                  include("logs.#{region}.amazonaws.com")
                ))
      end
    end

    context 'when execute command cloudwatch encryption is disabled' do
      before(:context) do
        @plan = plan(role: :root) do |vars|
          vars.enable_execute_command_logging = true
          vars.enable_execute_command_cloudwatch_encryption = false
        end
      end

      it 'does not associate a KMS key with the execute command log group' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_cloudwatch_log_group',
            name: 'execute_command'
          ).with_attribute_value(:kms_key_id, nil))
      end
    end

    context 'when execute command log group retention is set' do
      execute_command_log_group_retention = 5

      before(:context) do
        @plan = plan(role: :root) do |vars|
          vars.enable_execute_command_logging = true
          vars.execute_command_log_group_retention =
            execute_command_log_group_retention
        end
      end

      it 'uses the provided log group retention' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_cloudwatch_log_group',
            name: 'execute_command'
          ).with_attribute_value(
            :retention_in_days, execute_command_log_group_retention
          ))
      end
    end
  end
end
