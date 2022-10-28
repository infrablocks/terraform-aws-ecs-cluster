# frozen_string_literal: true

require 'spec_helper'

describe 'Autoscaling Group' do
  subject(:auto_scaling_group) do
    autoscaling_group(output_for(:harness, 'autoscaling_group_name'))
  end

  include_context 'terraform'

  let(:component) { vars.component }
  let(:dep_id) { vars.deployment_identifier }
  let(:cluster_name) { vars.cluster_name }

  it { is_expected.to exist }

  its(:launch_configuration_name) do
    is_expected.to eq(output_for(:harness, 'launch_configuration_name'))
  end
end
