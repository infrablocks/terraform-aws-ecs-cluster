require 'spec_helper'

describe 'Autoscaling Group' do
  include_context :terraform

  subject { autoscaling_group(output_for(:harness, 'autoscaling_group_name')) }

  it { should exist }
  its(:min_size) { should eq(vars.cluster_minimum_size.to_i) }
  its(:max_size) { should eq(vars.cluster_maximum_size.to_i) }
  its(:launch_configuration_name) do
    should eq(output_for(:harness, 'launch_configuration_name'))
  end
  its(:desired_capacity) {
    should eq(vars.cluster_desired_capacity.to_i)
  }

  it 'uses all private subnets' do
    expect(subject.vpc_zone_identifier.split(','))
        .to(contain_exactly(
            *output_for(:prerequisites, 'private_subnet_ids', parse: true)))
  end

  it { should have_tag('Name').value("cluster-worker-#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}") }
  it { should have_tag('Component').value(vars.component) }
  it { should have_tag('DeploymentIdentifier').value(vars.deployment_identifier) }
  it { should have_tag('ClusterName').value(vars.cluster_name) }
  it { should have_tag('ImportantTag').value('important-value') }
end