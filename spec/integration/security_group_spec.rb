# frozen_string_literal: true

require 'spec_helper'

describe 'Security Group' do
  subject(:security_group) do
    security_group(
      "#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}"
    )
  end

  include_context 'terraform'

  it { is_expected.to exist }
  it { is_expected.to have_tag('Component').value(vars.component) }

  it {
    expect(security_group)
      .to have_tag('DeploymentIdentifier').value(vars.deployment_identifier)
  }

  it { is_expected.to have_tag('ImportantTag').value('important-value') }

  its(:vpc_id) do
    is_expected.to eq(output_for(:prerequisites, 'vpc_id'))
  end

  it 'outputs the security group ID' do
    expect(output_for(:harness, 'security_group_id'))
      .to(eq(security_group.id))
  end

  context 'when default ingress and egress are included' do
    # rubocop:disable RSpec/MultipleExpectations
    it('allows inbound TCP and UDP connectivity on all ports from any ' \
       'address within the VPC') do
      expect(security_group.inbound_rule_count).to(eq(1))

      ingress_rule = security_group.ip_permissions.first

      expect(ingress_rule.from_port).to(be_nil)
      expect(ingress_rule.to_port).to(be_nil)
      expect(ingress_rule.ip_protocol).to(eq('-1'))
      expect(ingress_rule.ip_ranges.map(&:cidr_ip)).to(eq(vars.allowed_cidrs))
    end

    it 'allows outbound TCP connectivity on all ports and protocols anywhere' do
      expect(security_group.outbound_rule_count).to(be(1))

      egress_rule = security_group.ip_permissions_egress.first

      expect(egress_rule.from_port).to(be_nil)
      expect(egress_rule.to_port).to(be_nil)
      expect(egress_rule.ip_protocol).to(eq('-1'))
      expect(egress_rule.ip_ranges.map(&:cidr_ip)).to(eq(vars.egress_cidrs))
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  context 'when default ingress and egress are not included' do
    before(:all) do
      reprovision(
        include_default_ingress_rule: 'no',
        include_default_egress_rule: 'no'
      )
    end

    it 'has no ingress or egress rules' do
      expect(security_group.inbound_rule_count).to(eq(0))
    end

    it 'has no egress rules' do
      expect(security_group.outbound_rule_count).to(eq(0))
    end
  end
end
