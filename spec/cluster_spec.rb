require 'spec_helper'

describe 'ECS Cluster' do
  include_context :terraform

  let(:component) { RSpec.configuration.component }
  let(:deployment_identifier) { RSpec.configuration.deployment_identifier }
  let(:cluster_name) { RSpec.configuration.cluster_name }
  let(:instance_type) { RSpec.configuration.instance_type }
  let(:image_id) { RSpec.configuration.image_id }

  context 'launch configuration' do
    subject {
      launch_configuration("cluster-#{component}-#{deployment_identifier}-#{cluster_name}")
    }

    it { should exist }
    its(:instance_type) { should eq(instance_type) }
    its(:image_id) { should eq(image_id) }
  end
end

