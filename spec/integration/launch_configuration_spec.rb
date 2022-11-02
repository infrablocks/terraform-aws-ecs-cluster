# frozen_string_literal: true

require 'spec_helper'

describe 'Launch Configuration' do
  launch_config(:launch_config) do
    launch_configuration(
      output_for(:harness, 'launch_configuration_name')
    )
  end

  include_context 'terraform'

  it 'does not add a docker block device' do # does this test do anything?
    expect(launch_config.block_device_mappings.size).to(eq(1))
  end

  context 'when custom security groups are provided' do # integration
    before(:all) do
      security_group_ids =
        output_for(:prerequisites, 'security_group_ids')
      reprovision(
        security_groups:
            "[\"#{security_group_ids.join('","')}\"]"
      )
    end

    it {
      expect(launch_config).to have_security_group(
        "#{vars.component}-#{vars.deployment_identifier}-0"
      )
    }

    it {
      expect(launch_config).to have_security_group(
        "#{vars.component}-#{vars.deployment_identifier}-1"
      )
    }

    it 'has correct number of security groups' do
      expect(launch_config.security_groups.size).to(eq(3))
    end
  end

  its(:key_name) do # integration
    is_expected.to eq(
      "cluster-#{vars.component}-#{vars.deployment_identifier}-" \
      "#{vars.cluster_name}"
    )
  end

  its(:user_data) do # integration? base64 decoding doesn't seem
    # to work in unit testing
    is_expected.to eq(Base64.strict_encode64(<<~DOC))
      #!/bin/bash
      echo "ECS_CLUSTER=#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}" > /etc/ecs/ecs.config
    DOC
  end

  it { # integration
    expect(launch_config).to have_security_group(
      "#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}"
    )
  }

  describe 'launch config name' do # prefix is unit tested, so do we need this?
    let(:launch_configuration_name) do
      output_for(:harness, 'launch_configuration_name')
    end

    it 'contains the component' do
      expect(launch_configuration_name).to(match(/#{vars.component}/))
    end

    it 'contains the deployment identifier' do
      expect(launch_configuration_name)
        .to(match(/#{vars.deployment_identifier}/))
    end

    it 'contains the cluster name' do
      expect(launch_configuration_name).to(match(/#{vars.cluster_name}/))
    end
  end
end
