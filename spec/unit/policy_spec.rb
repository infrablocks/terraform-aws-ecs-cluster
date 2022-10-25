# frozen_string_literal: true

require 'spec_helper'

describe 'assumable roles policy' do
  describe 'by default' do
    let(:policy_name) { var(role: :root, name: 'policy_name') }
    let(:policy_description) { var(role: :root, name: 'policy_description') }

    before(:context) do
      @plan = plan(role: :root)
    end

    it 'creates a policy' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_iam_policy')
              .once)
    end

    it 'uses the provided policy name' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_iam_policy')
              .with_attribute_value(:name, policy_name))
    end

    it 'uses the provided policy description' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_iam_policy')
              .with_attribute_value(:description, policy_description))
    end

    it 'does not allow any roles to be assumed' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_iam_policy')
              .with_attribute_value(
                :policy,
                a_policy_with_statement(
                  {
                    Effect: 'Allow',
                    Action: 'sts:AssumeRole'
                  },
                  { without_keys: [:Resource] }
                )
              ))
    end

    it 'outputs the policy ARN' do
      expect(@plan)
        .to(include_output_creation(name: 'policy_arn'))
    end
  end

  describe 'when one assumable role provided' do
    before(:context) do
      @role_arn = output(role: :prerequisites, name: 'test_role_1_arn')

      @plan = plan(role: :root) do |vars|
        vars.assumable_roles = [@role_arn]
      end
    end

    it 'allows the role to be assumed' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_iam_policy')
              .with_attribute_value(
                :policy,
                a_policy_with_statement(
                  Effect: 'Allow',
                  Action: 'sts:AssumeRole',
                  Resource: @role_arn
                )
              ))
    end
  end

  describe 'when many assumable roles provided' do
    before(:context) do
      @role_arn1 = output(role: :prerequisites, name: 'test_role_1_arn')
      @role_arn2 = output(role: :prerequisites, name: 'test_role_2_arn')
      @role_arn3 = output(role: :prerequisites, name: 'test_role_3_arn')

      @plan = plan(role: :root) do |vars|
        vars.assumable_roles = [@role_arn1, @role_arn2, @role_arn3]
      end
    end

    it 'allows all roles to be assumed' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_iam_policy')
              .with_attribute_value(
                :policy,
                a_policy_with_statement(
                  Effect: 'Allow',
                  Action: 'sts:AssumeRole',
                  Resource: [@role_arn1, @role_arn2, @role_arn3]
                )
              ))
    end
  end

  describe 'when no assumable roles provided' do
    before(:context) do
      @role_arn = output(role: :prerequisites, name: 'test_role_1_arn')

      @plan = plan(role: :root) do |vars|
        vars.assumable_roles = []
      end
    end

    it 'does not allow any roles to be assumed' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_iam_policy')
              .with_attribute_value(
                :policy,
                a_policy_with_statement(
                  {
                    Effect: 'Allow',
                    Action: 'sts:AssumeRole'
                  },
                  { without_keys: [:Resource] }
                )
              ))
    end
  end

  describe 'when nil value for assumable roles provided' do
    before(:context) do
      @role_arn = output(role: :prerequisites, name: 'test_role_1_arn')

      @plan = plan(role: :root) do |vars|
        vars.assumable_roles = nil
      end
    end

    it 'does not allow any roles to be assumed' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_iam_policy')
              .with_attribute_value(
                :policy,
                a_policy_with_statement(
                  {
                    Effect: 'Allow',
                    Action: 'sts:AssumeRole'
                  },
                  { without_keys: [:Resource] }
                )
              ))
    end
  end
end
