# # frozen_string_literal: true
#
# require 'spec_helper'
#
# describe 'Launch Configuration' do
#   launch_config(:launch_config) do
#     launch_configuration(
#       output_for(:harness, 'launch_configuration_name')
#     )
#   end
#
#   include_context 'terraform'
#
#   it { is_expected.to exist }
#   its(:instance_type) { is_expected.to eq(vars.cluster_instance_type) }
#
#   context 'when using latest amazon linux 2 optimised for ECS' do
#     let(:latest_amazon_linux_2_ecs_optimised_ami_id) do
#       response = ec2_client.describe_images(
#         {
#           owners: ['amazon'],
#           filters: [
#             {
#               name: 'name',
#               values: ['amzn2-ami-ecs-hvm-*-x86_64-ebs']
#             }
#           ]
#         }
#       )
#       most_recent_image = response.images.max_by do |image|
#         DateTime.parse(image.creation_date)
#       end
#
#       most_recent_image.image_id
#     end
#
#     its(:image_id) do
#       is_expected.to eq(latest_amazon_linux_2_ecs_optimised_ami_id)
#     end
#   end
#
#   it 'does not add a docker block device' do
#     expect(launch_config.block_device_mappings.size).to(eq(1))
#   end
#
#   context 'when custom security groups are provided' do
#     before(:all) do
#       security_group_ids =
#         output_for(:prerequisites, 'security_group_ids')
#       reprovision(
#         security_groups:
#             "[\"#{security_group_ids.join('","')}\"]"
#       )
#     end
#
#     it {
#       expect(launch_config).to have_security_group(
#         "#{vars.component}-#{vars.deployment_identifier}-0"
#       )
#     }
#
#     it {
#       expect(launch_config).to have_security_group(
#         "#{vars.component}-#{vars.deployment_identifier}-1"
#       )
#     }
#
#     it 'has correct number of security groups' do
#       expect(launch_config.security_groups.size).to(eq(3))
#     end
#   end
#
#   context 'when AMIs specified' do
#     it 'uses provided image ID' do
#       ami_id = configuration.for(:harness).ami_id_in_region
#       puts ami_id
#       reprovision(
#         cluster_instance_amis:
#             "{#{vars.region}=\"#{ami_id}\"}"
#       )
#
#       expect(
#         launch_configuration(
#           output_for(:harness, 'launch_configuration_name')
#         )
#             .image_id
#       ).to eq(ami_id)
#     end
#   end
#
#   its(:key_name) do
#     is_expected.to eq(
#       "cluster-#{vars.component}-#{vars.deployment_identifier}-" \
#       "#{vars.cluster_name}"
#     )
#   end
#
#   its(:iam_instance_profile) do
#     is_expected.to eq(
#       "cluster-instance-profile-#{vars.component}-" \
#       "#{vars.deployment_identifier}-#{vars.cluster_name}"
#     )
#   end
#
#   its(:user_data) do
#     is_expected.to eq(Base64.strict_encode64(<<~DOC))
#       #!/bin/bash
#       echo "ECS_CLUSTER=#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}" > /etc/ecs/ecs.config
#     DOC
#   end
#
#   it {
#     expect(launch_config).to have_security_group(
#       "#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}"
#     )
#   }
#
#   describe 'launch config name' do
#     let(:launch_configuration_name) do
#       output_for(:harness, 'launch_configuration_name')
#     end
#
#     it 'contains the component' do
#       expect(launch_configuration_name).to(match(/#{vars.component}/))
#     end
#
#     it 'contains the deployment identifier' do
#       expect(launch_configuration_name)
#         .to(match(/#{vars.deployment_identifier}/))
#     end
#
#     it 'contains the cluster name' do
#       expect(launch_configuration_name).to(match(/#{vars.cluster_name}/))
#     end
#   end
#
#   it 'uses the specified size for the root block device' do
#     root_device_mapping = launch_config.block_device_mappings.find do |d|
#       d.device_name != '/dev/xvdcz'
#     end
#     expect(root_device_mapping.ebs.volume_size)
#       .to(eq(vars.cluster_instance_root_block_device_size.to_i))
#   end
# end
