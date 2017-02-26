require 'spec_helper'
require 'json'

describe 'IAM policies, profiles and roles' do
  include_context :terraform

  let(:component) { RSpec.configuration.component }
  let(:deployment_identifier) { RSpec.configuration.deployment_identifier }
  let(:cluster_name) { RSpec.configuration.cluster_name }

  context 'cluster instance profile' do
    subject {
      instance_profile_response = iam_client.get_instance_profile({
          instance_profile_name: "cluster-instance-profile-#{component}-#{deployment_identifier}-#{cluster_name}",
      })
      instance_profile_response.instance_profile
    }

    it 'has path /' do
      expect(subject.path).to(eq('/'))
    end

    it 'has the cluster instance role' do
      expect(subject.roles.first.role_name)
          .to(eq("cluster-instance-role-#{component}-#{deployment_identifier}-#{cluster_name}"))
    end
  end

  context 'cluster instance role' do
    subject {
      iam_role("cluster-instance-role-#{component}-#{deployment_identifier}-#{cluster_name}")
    }

    it { should exist }
    it 'allows assuming a role of ec2' do
      policy_document = JSON.parse(URI.decode(subject.assume_role_policy_document))
      expect(policy_document["Statement"].count).to(eq(1))

      policy_document_statement = policy_document["Statement"].first

      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Action']).to(eq('sts:AssumeRole'))
      expect(policy_document_statement['Principal']['Service']).to(eq('ec2.amazonaws.com'))
    end

    it {
      should have_iam_policy("cluster-instance-policy-#{component}-#{deployment_identifier}-#{cluster_name}")
    }
  end

  context 'cluster instance policy' do
    subject {
      iam_policy("cluster-instance-policy-#{component}-#{deployment_identifier}-#{cluster_name}")
    }

    let(:policy_document) do
      policy_version_response = iam_client.get_policy_version({
          policy_arn: subject.arn,
          version_id: subject.default_version_id,
      })

      JSON.parse(URI.decode(
          policy_version_response.policy_version.document))
    end

    it { should exist }

    it 'allows ECS actions' do
      expect(policy_document["Statement"].count).to(eq(1))

      policy_document_statement = policy_document["Statement"].first
      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Resource']).to(eq('*'))
      expect(policy_document_statement['Action']).to(include('ecs:CreateCluster'))
      expect(policy_document_statement['Action']).to(include('ecs:RegisterContainerInstance'))
      expect(policy_document_statement['Action']).to(include('ecs:DeregisterContainerInstance'))
      expect(policy_document_statement['Action']).to(include('ecs:DiscoverPollEndpoint'))
      expect(policy_document_statement['Action']).to(include('ecs:Poll'))
      expect(policy_document_statement['Action']).to(include('ecs:StartTelemetrySession'))
      expect(policy_document_statement['Action']).to(include('ecs:Submit*'))
    end

    it 'allows log creation' do
      expect(policy_document["Statement"].count).to(eq(1))

      policy_document_statement = policy_document["Statement"].first
      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Resource']).to(eq('*'))
      expect(policy_document_statement['Action']).to(include('logs:CreateLogStream'))
      expect(policy_document_statement['Action']).to(include('logs:PutLogEvents'))
    end

    it 'allows ECR images to be pulled' do
      expect(policy_document["Statement"].count).to(eq(1))

      policy_document_statement = policy_document["Statement"].first
      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Resource']).to(eq('*'))
      expect(policy_document_statement['Action']).to(include('ecr:GetAuthorizationToken'))
      expect(policy_document_statement['Action']).to(include('ecr:GetDownloadUrlForLayer'))
      expect(policy_document_statement['Action']).to(include('ecr:BatchGetImage'))
      expect(policy_document_statement['Action']).to(include('ecr:BatchCheckLayerAvailability'))
    end

    it 'allows objects to be fetched from S3' do
      expect(policy_document["Statement"].count).to(eq(1))

      policy_document_statement = policy_document["Statement"].first
      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Resource']).to(eq('*'))
      expect(policy_document_statement['Action']).to(include('s3:GetObject'))
    end
  end

  context 'cluster service role' do
    subject {
      iam_role("cluster-service-role-#{component}-#{deployment_identifier}-#{cluster_name}")
    }

    it { should exist }
    it 'allows assuming a role of ecs' do
      policy_document = JSON.parse(URI.decode(subject.assume_role_policy_document))
      expect(policy_document["Statement"].count).to(eq(1))

      policy_document_statement = policy_document["Statement"].first

      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Action']).to(eq('sts:AssumeRole'))
      expect(policy_document_statement['Principal']['Service']).to(eq('ecs.amazonaws.com'))
    end

    it {
      should have_iam_policy("cluster-service-policy-#{component}-#{deployment_identifier}-#{cluster_name}")
    }
  end

  context 'cluster service policy' do
    subject {
      iam_policy("cluster-service-policy-#{component}-#{deployment_identifier}-#{cluster_name}")
    }

    let(:policy_document) do
      policy_version_response = iam_client.get_policy_version({
          policy_arn: subject.arn,
          version_id: subject.default_version_id,
      })

      JSON.parse(URI.decode(
          policy_version_response.policy_version.document))
    end

    it { should exist }

    it 'allows ELB actions' do
      expect(policy_document["Statement"].count).to(eq(1))

      policy_document_statement = policy_document["Statement"].first
      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Resource']).to(eq('*'))
      expect(policy_document_statement['Action']).to(include('elasticloadbalancing:RegisterInstancesWithLoadBalancer'))
      expect(policy_document_statement['Action']).to(include('elasticloadbalancing:DeregisterInstancesFromLoadBalancer'))
      expect(policy_document_statement['Action']).to(include('elasticloadbalancing:Describe*'))
    end

    it 'allows EC2 ingress and describe actions' do
      expect(policy_document["Statement"].count).to(eq(1))

      policy_document_statement = policy_document["Statement"].first
      expect(policy_document_statement['Effect']).to(eq('Allow'))
      expect(policy_document_statement['Resource']).to(eq('*'))
      expect(policy_document_statement['Action']).to(include('ec2:Describe*'))
      expect(policy_document_statement['Action']).to(include('ec2:AuthorizeSecurityGroupIngress'))
    end

    context 'outputs' do
      let(:cluster_instance_role) {
        iam_role("cluster-instance-role-#{component}-#{deployment_identifier}-#{cluster_name}")
      }
      let(:cluster_service_role){
        iam_role("cluster-service-role-#{component}-#{deployment_identifier}-#{cluster_name}")
      }

      it 'outputs instance role arn' do
        instance_role_arn = Terraform.output(name: 'instance_role_arn')
        expect(instance_role_arn).to(eq(cluster_instance_role.arn))
      end

      it 'outputs instance role id' do
        instance_role_id = Terraform.output(name: 'instance_role_id')
        expect(instance_role_id).to(eq(cluster_instance_role.role_id))
      end

      it 'outputs service role arn' do
        service_role_arn = Terraform.output(name: 'service_role_arn')
        expect(service_role_arn).to(eq(cluster_service_role.arn))
      end

      it 'outputs service role id' do
        service_role_id = Terraform.output(name: 'service_role_id')
        expect(service_role_id).to(eq(cluster_service_role.role_id))
      end
    end
  end
end
