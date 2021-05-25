require 'spec_helper'

describe 'Autoscaling Group' do
  include_context :terraform

  subject { autoscaling_group(output_for(:harness, 'autoscaling_group_name')) }

  let(:component) { vars.component }
  let(:dep_id) { vars.deployment_identifier }
  let(:cluster_name) { vars.cluster_name }

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
            *output_for(:prerequisites, 'private_subnet_ids')))
  end

  it do
    should(have_tag('Name')
        .value("cluster-worker-#{component}-#{dep_id}-#{cluster_name}"))
  end
  it { should have_tag('Component').value(component) }
  it { should have_tag('DeploymentIdentifier').value(dep_id) }
  it { should have_tag('ClusterName').value(cluster_name) }
  it { should have_tag('ImportantTag').value('important-value') }

  context 'when scale in protection enabled' do
    before(:all) do
      reprovision(protect_cluster_instances_from_scale_in: "yes")
    end

    its(:new_instances_protected_from_scale_in) { should(eq(true)) }
  end

  context 'when scale in protection disabled' do
    before(:all) do
      reprovision(protect_cluster_instances_from_scale_in: "no")
    end

    its(:new_instances_protected_from_scale_in) { should(eq(false)) }
  end
end
