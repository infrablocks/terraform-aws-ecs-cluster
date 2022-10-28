# frozen_string_literal: true

require 'spec_helper'
require 'json'

describe 'IAM policies, profiles and roles' do
  include_context 'terraform'

  describe 'cluster instance profile' do
    subject(:instance_profile) do
      instance_profile_name =
        "cluster-instance-profile-#{vars.component}-" \
        "#{vars.deployment_identifier}-#{vars.cluster_name}"

      iam_client
        .get_instance_profile({ instance_profile_name: })
        .instance_profile
    end

    it 'has the cluster instance role' do # integration
      expect(instance_profile.roles.first.role_name)
        .to(eq(iam_role(output_for(:harness, 'instance_role_id')).name))
    end
  end

  # rubocop:disable RSpec/MultipleExpectations
  describe 'cluster instance role' do
    subject(:role) do
      iam_role(output_for(:harness, 'instance_role_id'))
    end

    it 'allows assuming a role of ec2' do
      policy_document =
        JSON.parse(CGI.unescape(role.assume_role_policy_document))
      expect(policy_document['Statement'].count).to(eq(1))

      policy_document_statement = policy_document['Statement'].first

      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Action']).to(eq('sts:AssumeRole'))
      expect(policy_document_statement['Principal']['Service'])
        .to(eq('ec2.amazonaws.com'))
    end

    it {
      expect(role).to have_iam_policy(output_for(:harness,
                                                 'instance_policy_id'))
    }
  end

  describe 'cluster instance policy' do
    subject(:policy) do
      iam_policy(output_for(:harness, 'instance_policy_id'))
    end

    let(:policy_document) do
      policy_version_response =
        iam_client.get_policy_version({
                                        policy_arn: policy.arn,
                                        version_id: policy.default_version_id
                                      })

      JSON.parse(CGI.unescape(
                   policy_version_response.policy_version.document
                 ))
    end

    it { is_expected.to exist }

    it 'has correct description' do
      policy = iam_client
               .get_policy(policy_arn: output_for(:harness,
                                                  'instance_policy_arn'))
               .policy

      expect(policy.description)
        .to(eq("cluster-instance-policy-#{vars.component}-" \
               "#{vars.deployment_identifier}-#{vars.cluster_name}"))
    end

    it 'allows ECS actions' do
      expect(policy_document['Statement'].count).to(eq(1))

      policy_document_statement = policy_document['Statement'].first
      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Resource']).to(eq('*'))
      expect(policy_document_statement['Action'])
        .to(include('ecs:CreateCluster'))
      expect(policy_document_statement['Action'])
        .to(include('ecs:RegisterContainerInstance'))
      expect(policy_document_statement['Action'])
        .to(include('ecs:DeregisterContainerInstance'))
      expect(policy_document_statement['Action'])
        .to(include('ecs:DiscoverPollEndpoint'))
      expect(policy_document_statement['Action'])
        .to(include('ecs:Poll'))
      expect(policy_document_statement['Action'])
        .to(include('ecs:StartTelemetrySession'))
      expect(policy_document_statement['Action'])
        .to(include('ecs:Submit*'))
    end

    it 'allows log creation' do
      expect(policy_document['Statement'].count).to(eq(1))

      policy_document_statement = policy_document['Statement'].first
      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Resource']).to(eq('*'))
      expect(policy_document_statement['Action'])
        .to(include('logs:CreateLogStream'))
      expect(policy_document_statement['Action'])
        .to(include('logs:PutLogEvents'))
    end

    it 'allows ECR images to be pulled' do
      expect(policy_document['Statement'].count).to(eq(1))

      policy_document_statement = policy_document['Statement'].first
      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Resource']).to(eq('*'))
      expect(policy_document_statement['Action'])
        .to(include('ecr:GetAuthorizationToken'))
      expect(policy_document_statement['Action'])
        .to(include('ecr:GetDownloadUrlForLayer'))
      expect(policy_document_statement['Action'])
        .to(include('ecr:BatchGetImage'))
      expect(policy_document_statement['Action'])
        .to(include('ecr:BatchCheckLayerAvailability'))
    end

    it 'allows objects to be fetched from S3' do
      expect(policy_document['Statement'].count).to(eq(1))

      policy_document_statement = policy_document['Statement'].first
      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Resource']).to(eq('*'))
      expect(policy_document_statement['Action']).to(include('s3:GetObject'))
    end
  end

  describe 'cluster service role' do
    subject(:cluster_instance_role) do
      iam_role(output_for(:harness, 'service_role_id'))
    end

    it { is_expected.to exist }

    its(:description) do
      is_expected.to eq("cluster-service-role-#{vars.component}-" \
                        "#{vars.deployment_identifier}-#{vars.cluster_name}")
    end

    it 'allows assuming a role of ecs' do
      policy_document =
        JSON.parse(
          CGI.unescape(cluster_instance_role.assume_role_policy_document)
        )
      expect(policy_document['Statement'].count).to(eq(1))

      policy_document_statement = policy_document['Statement'].first

      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Action']).to(eq('sts:AssumeRole'))
      expect(policy_document_statement['Principal']['Service'])
        .to(eq('ecs.amazonaws.com'))
    end

    it {
      expect(cluster_instance_role)
        .to have_iam_policy(output_for(:harness,
                                       'service_policy_id'))
    }
  end

  describe 'cluster service policy' do
    subject(:service_policy) do
      iam_policy(output_for(:harness, 'service_policy_id'))
    end

    let(:policy_document) do
      policy_version_response =
        iam_client
        .get_policy_version({
                              policy_arn: service_policy.arn,
                              version_id: service_policy.default_version_id
                            })

      JSON.parse(CGI.unescape(
                   policy_version_response.policy_version.document
                 ))
    end

    it { is_expected.to exist }

    it 'has correct description' do
      policy = iam_client
               .get_policy(policy_arn: output_for(:harness,
                                                  'service_policy_arn'))
               .policy

      expect(policy.description)
        .to(eq("cluster-service-policy-#{vars.component}-" \
               "#{vars.deployment_identifier}-#{vars.cluster_name}"))
    end

    it 'allows ELB actions' do
      expect(policy_document['Statement'].count).to(eq(1))

      policy_document_statement = policy_document['Statement'].first
      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Resource']).to(eq('*'))
      expect(policy_document_statement['Action'])
        .to(include('elasticloadbalancing:RegisterInstancesWithLoadBalancer'))
      expect(policy_document_statement['Action'])
        .to(include('elasticloadbalancing:DeregisterInstancesFromLoadBalancer'))
      expect(policy_document_statement['Action'])
        .to(include('elasticloadbalancing:Describe*'))
      expect(policy_document_statement['Action'])
        .to(include('elasticloadbalancing:RegisterTargets'))
      expect(policy_document_statement['Action'])
        .to(include('elasticloadbalancing:DeregisterTargets'))
    end

    it 'allows EC2 ingress and describe actions' do
      expect(policy_document['Statement'].count).to(eq(1))

      policy_document_statement = policy_document['Statement'].first
      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Resource']).to(eq('*'))
      expect(policy_document_statement['Action'])
        .to(include('ec2:Describe*'))
      expect(policy_document_statement['Action'])
        .to(include('ec2:AuthorizeSecurityGroupIngress'))
    end
    # rubocop:enable RSpec/MultipleExpectations

    describe 'outputs' do
      let(:cluster_instance_role) do
        iam_role(output_for(:harness, 'instance_role_id'))
      end
      let(:cluster_service_role) do
        iam_role(output_for(:harness, 'service_role_id'))
      end
      let(:cluster_instance_policy) do
        iam_policy(output_for(:harness, 'instance_policy_id'))
      end
      let(:cluster_service_policy) do
        iam_policy(output_for(:harness, 'service_policy_id'))
      end

      it 'outputs instance role arn' do
        expect(output_for(:harness, 'instance_role_arn'))
          .to(eq(cluster_instance_role.arn))
      end

      it 'outputs instance role id' do
        expect(output_for(:harness, 'instance_role_id'))
          .to(eq(cluster_instance_role.role_id))
      end

      it 'outputs instance policy arn' do
        expect(output_for(:harness, 'instance_policy_arn'))
          .to(eq(cluster_instance_policy.arn))
      end

      it 'outputs service role arn' do
        expect(output_for(:harness, 'service_role_arn'))
          .to(eq(cluster_service_role.arn))
      end

      it 'outputs service role id' do
        expect(output_for(:harness, 'service_role_id'))
          .to(eq(cluster_service_role.role_id))
      end

      it 'outputs service policy arn' do
        expect(output_for(:harness, 'service_policy_arn'))
          .to(eq(cluster_service_policy.arn))
      end
    end
  end
end
