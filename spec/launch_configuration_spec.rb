require 'spec_helper'

describe 'Launch Configuration' do
  include_context :terraform

  subject {
    launch_configuration(output_for(:harness, 'launch_configuration_name'))
  }

  it { should exist }
  its(:instance_type) { should eq(vars.cluster_instance_type) }

  context 'uses latest amazon linux 2 optimised for ECS' do
    let(:latest_amazon_linux_2_ecs_optimised_ami_id) {
      response = ec2_client.describe_images(
          {
              owners: ['amazon'],
              filters: [
                  {
                      name: 'name',
                      values: ['amzn2-ami-ecs-hvm-*-x86_64-ebs']
                  }
              ]
          })
      most_recent_image = response.images.max_by do |image|
        DateTime.parse(image.creation_date)
      end

      most_recent_image.image_id
    }

    its(:image_id) do
      should eq(latest_amazon_linux_2_ecs_optimised_ami_id)
    end
  end

  it 'does not add a docker block device' do
    expect(subject.block_device_mappings.size).to(eq(1))
  end

  context 'when custom security groups are provided' do
    before(:all) do
      security_group_ids =
          output_for(:prerequisites, 'security_group_ids')
      reprovision(
          security_groups:
              '["' + security_group_ids.join('","') + '"]'
      )
    end

    it { should have_security_group("#{vars.component}-#{vars.deployment_identifier}-0") }
    it { should have_security_group("#{vars.component}-#{vars.deployment_identifier}-1") }

    it 'should have correct number of security groups' do
      expect(subject.security_groups.size).to(eq(3))
    end
  end

  context 'when AMIs specified' do
    it 'uses provided image ID' do
      ami_id = configuration.for(:harness).ami_id_in_region
      puts ami_id
      reprovision(
          cluster_instance_amis:
              '{' + vars.region + '="' + ami_id + '"}')

      expect(
          launch_configuration(
              output_for(:harness, 'launch_configuration_name'))
              .image_id).to eq(ami_id)
    end
  end

  its(:key_name) do
    should eq("cluster-#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}")
  end

  its(:iam_instance_profile) do
    should eq("cluster-instance-profile-#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}")
  end

  its(:user_data) do
    should eq(Base64.strict_encode64(<<~DOC))
      #!/bin/bash
      echo "ECS_CLUSTER=#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}" > /etc/ecs/ecs.config
    DOC
  end

  it { should have_security_group("#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}") }

  it 'has a name containing the component, deployment_identifier and cluster_name' do
    launch_configuration_name = output_for(:harness, 'launch_configuration_name')

    expect(launch_configuration_name).to(match(/#{vars.component}/))
    expect(launch_configuration_name).to(match(/#{vars.deployment_identifier}/))
    expect(launch_configuration_name).to(match(/#{vars.cluster_name}/))
  end

  it 'uses the specified size for the root block device' do
    root_device_mapping = subject.block_device_mappings.find do |d|
      d.device_name != '/dev/xvdcz'
    end
    expect(root_device_mapping.ebs.volume_size)
        .to(eq(vars.cluster_instance_root_block_device_size.to_i))
  end
end
