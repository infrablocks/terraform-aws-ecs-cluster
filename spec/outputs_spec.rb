require 'spec_helper'

describe 'Outputs' do
  include_context :terraform

  let(:cluster) { ecs_cluster("#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}") }
  let(:asg) { autoscaling_group(output_for(:harness, 'autoscaling_group_name')) }

  it 'outputs the cluster id' do
    expect(output_for(:harness, 'cluster_id'))
        .to(eq(cluster.cluster_arn))
  end

  it 'outputs the cluster name' do
    expect(output_for(:harness, 'cluster_name'))
        .to(eq(cluster.cluster_name))
  end

  it 'outputs the autoscaling group name' do
    expect(output_for(:harness, 'autoscaling_group_name'))
        .to(eq(asg.auto_scaling_group_name))
  end
end
