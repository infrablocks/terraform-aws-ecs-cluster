# frozen_string_literal: true

require 'spec_helper'
require 'json'

describe 'IAM policies, profiles and roles' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:dep_id) do
    var(role: :root, name: 'deployment_identifier')
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root)
    end

    describe 'cluster instance profile' do
      it 'exists' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_iam_instance_profile')
                .once)
      end

      it 'has path /' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_iam_instance_profile')
                .with_attribute_value(:path, '/'))
      end
    end

    describe 'cluster instance role' do
      it 'exists' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_iam_role',
            name: 'cluster_instance_role'
          )
                .once)
      end

      it('has description') do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_iam_role',
            name: 'cluster_instance_role'
          )
                .with_attribute_value(
                  :description,
                  "cluster-instance-role-#{component}-#{dep_id}-default"
                ))
      end

      it 'allows assuming a role of ec2' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_iam_role',
            name: 'cluster_instance_role'
          )
                .with_attribute_value(
                  :assume_role_policy,
                  a_policy_with_statement(
                    Effect: 'Allow',
                    Action: 'sts:AssumeRole',
                    Principal: { Service: ['ec2.amazonaws.com'] }
                  )
                ))
      end
    end

    describe 'cluster instance policy' do
      it 'exists' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_iam_policy',
            name: 'cluster_instance_policy'
          )
                .once)
      end

      it 'has correct description' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_iam_policy',
            name: 'cluster_instance_policy'
          )
                .with_attribute_value(
                  :description,
                  "cluster-instance-policy-#{component}-#{dep_id}-default"
                ))
      end

      it 'allows ECS, ECR, S3 and log actions' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_iam_policy',
            name: 'cluster_instance_policy'
          )
                .with_attribute_value(
                  :policy,
                  a_policy_with_statement(
                    Resource: '*',
                    Effect: 'Allow',
                    Action: %w[
                      ecs:CreateCluster
                      ecs:RegisterContainerInstance
                      ecs:DeregisterContainerInstance
                      ecs:DiscoverPollEndpoint
                      ecs:Poll
                      ecs:StartTelemetrySession
                      ecs:Submit*
                      ecr:GetAuthorizationToken
                      ecr:GetDownloadUrlForLayer
                      ecr:BatchGetImage
                      ecr:BatchCheckLayerAvailability
                      s3:GetObject
                      logs:CreateLogStream
                      logs:PutLogEvents
                    ]
                  )
                ))
      end
    end

    describe 'cluster service role' do
      it 'exists' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_iam_role',
            name: 'cluster_service_role'
          )
                .once)
      end

      it 'has correct description' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_iam_role',
            name: 'cluster_service_role'
          )
                .with_attribute_value(
                  :description,
                  "cluster-service-role-#{component}-#{dep_id}-default"
                ))
      end

      it 'allows assuming a role of ecs' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_iam_role',
            name: 'cluster_service_role'
          )
                .with_attribute_value(
                  :assume_role_policy,
                  a_policy_with_statement(
                    Effect: 'Allow',
                    Action: 'sts:AssumeRole',
                    Principal: { Service: ['ecs.amazonaws.com'] }
                  )
                ))
      end
    end

    describe 'cluster service policy' do
      it 'exists' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_iam_policy',
            name: 'cluster_service_policy'
          )
                .once)
      end

      it 'has correct description' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_iam_policy',
            name: 'cluster_service_policy'
          )
                .with_attribute_value(
                  :description,
                  "cluster-service-policy-#{component}-#{dep_id}-default"
                ))
      end

      it 'allows ELB, EC2 ingress and describe actions' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_iam_policy',
            name: 'cluster_service_policy'
          )
                .with_attribute_value(
                  :policy,
                  a_policy_with_statement(
                    Resource: '*',
                    Effect: 'Allow',
                    Action: %w[
                      elasticloadbalancing:RegisterInstancesWithLoadBalancer
                      elasticloadbalancing:DeregisterInstancesFromLoadBalancer
                      elasticloadbalancing:Describe*
                      elasticloadbalancing:RegisterTargets
                      elasticloadbalancing:DeregisterTargets
                      ec2:Describe*
                      ec2:AuthorizeSecurityGroupIngress
                    ]
                  )
                ))
      end
    end
  end

  describe 'when include_cluster_instances is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_cluster_instances = false
      end
    end

    describe 'cluster instance profile' do
      it 'does not exist' do
        expect(@plan)
          .not_to(include_resource_creation(type: 'aws_iam_instance_profile'))
      end
    end

    describe 'cluster instance role' do
      it 'does not exist' do
        expect(@plan)
          .not_to(include_resource_creation(
                    type: 'aws_iam_role',
                    name: 'cluster_instance_role'
                  ))
      end
    end

    describe 'cluster instance policy' do
      it 'does not exist' do
        expect(@plan)
          .not_to(include_resource_creation(
                    type: 'aws_iam_policy',
                    name: 'cluster_instance_policy'
                  ))
      end
    end
  end

  describe 'when include_cluster_instances is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_cluster_instances = true
      end
    end

    describe 'cluster instance profile' do
      it 'exists' do
        expect(@plan)
          .to(include_resource_creation(type: 'aws_iam_instance_profile')
                .once)
      end
    end

    describe 'cluster instance role' do
      it 'exists' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_iam_role',
            name: 'cluster_instance_role'
          ).once)
      end
    end

    describe 'cluster instance policy' do
      it 'exists' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_iam_policy',
            name: 'cluster_instance_policy'
          ).once)
      end
    end
  end
end
