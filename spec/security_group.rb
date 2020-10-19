require 'spec_helper'

describe 'Security Group' do
  include_context :terraform

  subject { security_group("#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}") }

  it { should exist }
  it { should have_tag('Component').value(vars.component) }
  it { should have_tag('DeploymentIdentifier').value(vars.deployment_identifier) }
  it { should have_tag('ImportantTag').value('important-value') }
  its(:vpc_id) { should eq(output_for(:prerequisites, 'vpc_id')) }

  it 'outputs the security group ID' do
    expect(output_for(:harness, 'security_group_id')).to(eq(subject.id))
  end

  context 'when default ingress and egress are included' do
    it('allows inbound TCP and UDP connectivity on all ports from any ' +
        'address within the VPC') do
      expect(subject.inbound_rule_count).to(eq(1))

      ingress_rule = subject.ip_permissions.first

      expect(ingress_rule.from_port).to(be_nil)
      expect(ingress_rule.to_port).to(be_nil)
      expect(ingress_rule.ip_protocol).to(eq('-1'))
      expect(ingress_rule.ip_ranges.map(&:cidr_ip)).to(eq(vars.allowed_cidrs))
    end

    it 'allows outbound TCP connectivity on all ports and protocols anywhere' do
      expect(subject.outbound_rule_count).to(be(1))

      egress_rule = subject.ip_permissions_egress.first

      expect(egress_rule.from_port).to(be_nil)
      expect(egress_rule.to_port).to(be_nil)
      expect(egress_rule.ip_protocol).to(eq('-1'))
      expect(egress_rule.ip_ranges.map(&:cidr_ip)).to(eq(vars.egress_cidrs))
    end
  end

  context 'when default ingress and egress are not included' do
    before(:all) do
      reprovision(
          include_default_ingress_rule: 'no',
          include_default_egress_rule: 'no')
    end

    it 'has no ingress or egress rules' do
      expect(subject.inbound_rule_count).to(eq(0))
      expect(subject.outbound_rule_count).to(eq(0))
    end
  end
end
