# frozen_string_literal: true

require 'spec_helper'

describe 'autoscaling group' do
  describe 'by default' do
    let(:component) do
      var(role: :root, name: 'component')
    end
    let(:some_output) do
      output(role: :prerequisites, name: 'certificate_arn')
    end

    before(:context) do
      @plan = plan(role: :root)
    end

    it 'creates a autoscaling group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_autoscaling_group')
              .once)
    end

    it 'uses a minimum cluster size of 1' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_autoscaling_group')
              .with_attribute_value(:min_size, 1))
    end

    it 'outputs something important' do
      expect(@plan)
        .to(include_output_creation(name: 'important_output')
              .with_value(36))
    end
  end

  describe 'when cluster sizes provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.cluster_minimum_size = 2
        vars.cluster_maximum_size = 5
        vars.cluster_desired_capacity = 3
      end
    end

    it 'uses the provided minimum cluster size' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_autoscaling_group')
              .with_attribute_value(:min_size, 2))
    end
  end
end
#   subject(:auto_scaling_group) do
#     autoscaling_group(output_for(:harness, 'autoscaling_group_name'))
#   end
#
#   include_context 'terraform'
#
#   let(:component) { vars.component }
#   let(:dep_id) { vars.deployment_identifier }
#   let(:cluster_name) { vars.cluster_name }
#
#   it { is_expected.to exist }
#   its(:min_size) { is_expected.to eq(vars.cluster_minimum_size.to_i) }
#   its(:max_size) { is_expected.to eq(vars.cluster_maximum_size.to_i) }
#
#   its(:launch_configuration_name) do
#     is_expected.to eq(output_for(:harness, 'launch_configuration_name'))
#   end
#
#   its(:desired_capacity) do
#     is_expected.to eq(vars.cluster_desired_capacity.to_i)
#   end
#
#   it 'uses all private subnets' do
#     expect(auto_scaling_group.vpc_zone_identifier.split(','))
#       .to(contain_exactly(
#             *output_for(:prerequisites, 'private_subnet_ids')
#           ))
#   end
#
#   it do
#     expect(auto_scaling_group).to(have_tag('Name')
#         .value("cluster-worker-#{component}-#{dep_id}-#{cluster_name}"))
#   end
#
#   it { is_expected.to have_tag('Component').value(component) }
#   it { is_expected.to have_tag('DeploymentIdentifier').value(dep_id) }
#   it { is_expected.to have_tag('ClusterName').value(cluster_name) }
#   it { is_expected.to have_tag('ImportantTag').value('important-value') }
#
#   context 'when scale in protection enabled' do
#     before(:all) do
#       reprovision(protect_cluster_instances_from_scale_in: 'yes')
#     end
#
#     its(:new_instances_protected_from_scale_in) do
#       is_expected.to(be(true))
#     end
#   end
#
#   context 'when scale in protection disabled' do
#     before(:all) do
#       reprovision(protect_cluster_instances_from_scale_in: 'no')
#     end
#
#     its(:new_instances_protected_from_scale_in) do
#       is_expected.to(be(false))
#     end
#   end
# end
