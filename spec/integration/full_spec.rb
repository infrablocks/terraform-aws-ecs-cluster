# frozen_string_literal: true

require 'spec_helper'

describe 'full example' do
  subject { iam_policy(policy_name) }

  before(:context) do
    apply(role: :full)
  end

  after(:context) do
    destroy(role: :full)
  end

  let(:policy_name) do
    var(role: :full, name: 'policy_name')
  end
  let(:policy_description) do
    var(role: :full, name: 'policy_description')
  end

  let(:policy_arn) do
    output(role: :full, name: 'policy_arn')
  end
  let(:target_role_arn) do
    output(role: :full, name: 'target_role_arn')
  end

  let(:assumable_role_1_arn) do
    output(role: :full, name: 'assumable_role_1_arn')
  end
  let(:assumable_role_2_arn) do
    output(role: :full, name: 'assumable_role_2_arn')
  end
  let(:assumable_role_3_arn) do
    output(role: :full, name: 'assumable_role_3_arn')
  end

  let(:assumable_roles) do
    [assumable_role_1_arn, assumable_role_2_arn, assumable_role_3_arn]
  end

  let(:target_role) do
    iam_role(target_role_arn)
  end

  it { is_expected.to exist }
  its(:arn) { is_expected.to eq(policy_arn) }

  it 'allows all assumable roles to be assumed' do
    assumable_roles.each do |role|
      expect(target_role)
        .to(be_allowed_action('sts:AssumeRole')
          .resource_arn(role))
    end
  end
end
