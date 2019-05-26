Terraform AWS ECS Cluster
=========================

[![CircleCI](https://circleci.com/gh/infrablocks/terraform-aws-ecs-cluster.svg?style=svg)](https://circleci.com/gh/infrablocks/terraform-aws-ecs-cluster)

A Terraform module for building an ECS Cluster in AWS.

The ECS cluster requires:
* An existing VPC
* Some existing subnets
 
The ECS cluster consists of:
* A cluster in ECS
* A launch configuration and auto-scaling group for a cluster of ECS container 
  instances
* An SSH key to connect to the ECS container instances
* A security group for the container instances optionally allowing:
  * Outbound internet access for all containers
  * Inbound TCP access on any port from the VPC network
* An IAM role and policy for the container instances allowing:
  * ECS interactions
  * ECR image pulls
  * S3 object fetches
  * Logging to cloudwatch
* An IAM role and policy for ECS services allowing:
  * Elastic load balancer registration / deregistration
  * EC2 describe actions and security group ingress rule creation
* A CloudWatch log group

![Diagram of infrastructure managed by this module](https://raw.githubusercontent.com/infrablocks/terraform-aws-ecs-cluster/master/docs/architecture.png)

Usage
-----

To use the module, include something like the following in your terraform 
configuration:

```hcl-terraform
module "ecs_cluster" {
  source = "infrablocks/ecs-cluster/aws"
  version = "0.2.5"
  
  region = "eu-west-2"
  vpc_id = "vpc-fb7dc365"
  subnet_ids = "subnet-eb32c271,subnet-64872d1f"
  
  component = "important-component"
  deployment_identifier = "production"
  
  cluster_name = "services"
  cluster_instance_ssh_public_key_path = "~/.ssh/id_rsa.pub"
  cluster_instance_type = "t2.small"
  
  cluster_minimum_size = 2
  cluster_maximum_size = 10
  cluster_desired_capacity = 4
}
```

As mentioned above, the ECS cluster deploys into an existing base network. 
Whilst the base network can be created using any mechanism you like, the 
[AWS Base Networking](https://github.com/tobyclemson/terraform-aws-base-networking)
module will create everything you need. See the 
[docs](https://github.com/tobyclemson/terraform-aws-base-networking/blob/master/README.md)
for usage instructions.


### Inputs

| Name                                          | Description                                                                                                             | Default            | Required                                 |
|-----------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|:------------------:|:----------------------------------------:|
| region                                        | The region into which to deploy the cluster                                                                             | -                  | yes                                      |
| vpc_id                                        | The ID of the VPC into which to deploy the cluster                                                                      | -                  | yes                                      |
| subnet_ids                                    | The IDs of the subnets for container instances                                                                          | -                  | yes                                      |
| component                                     | The component this cluster will contain                                                                                 | -                  | yes                                      |
| deployment_identifier                         | An identifier for this instantiation                                                                                    | -                  | yes                                      |
| cluster_name                                  | The name of the cluster to create                                                                                       | default            | yes                                      |
| cluster_instance_ssh_public_key_path          | The path to the public key to use for the container instances                                                           | -                  | yes                                      |
| cluster_instance_type                         | The instance type of the container instances                                                                            | t2.medium          | yes                                      |
| cluster_instance_root_block_device_size       | The size in GB of the root block device on cluster instances                                                            | 30                 | yes                                      |
| cluster_instance_root_block_device_type       | The type of the root block device on cluster instances ('standard', 'gp2', or 'io1')                                    | standard           | yes                                      |
| cluster_instance_docker_block_device_size     | The size in GB of the docker block device on cluster instances (only applies to Amazon Linux 1)                         | 100                | yes                                      | 
| cluster_instance_docker_block_device_type     | The type of the docker block device on cluster instances ('standard', 'gp2', or 'io1') (only applies to Amazon Linux 1) | standard           | yes                                      |
| cluster_instance_docker_block_device_name     | The name of the docker block device on cluster instances (only applies to Amazon Linux 1)                               | /dev/xvdcz         | yes                                      |
| cluster_instance_user_data_template           | The contents of a template for container instance user data                                                             | see user-data      | no                                       |
| cluster_instance_default_amazon_linux_version | The version of Amazon Linux to use by default when no AMIs are provided                                                 | 2                  | no                                       |
| cluster_instance_amis                         | A map of regions to AMIs for the container instances                                                                    | ECS optimised AMIs | yes                                      |
| cluster_instance_iam_policy_contents          | The contents of the cluster instance IAM policy                                                                         | see policies       | no                                       |
| cluster_service_iam_policy_contents           | The contents of the cluster service IAM policy                                                                          | see policies       | no                                       |
| cluster_minimum_size                          | The minimum size of the ECS cluster                                                                                     | 1                  | yes                                      |
| cluster_maximum_size                          | The maximum size of the ECS cluster                                                                                     | 10                 | yes                                      |
| cluster_desired_capacity                      | The desired capacity of the ECS cluster                                                                                 | 3                  | yes                                      |
| associate_public_ip_addresses                 | Whether or not to associate public IP addresses with ECS container instances ("yes" or "no")                            | "no"               | yes                                      |
| include_default_ingress_rule                  | Whether or not to include the default ingress rule on the ECS container instances security group ("yes" or "no")        | "yes"              | yes                                      |
| include_default_egress_rule                   | Whether or not to include the default egress rule on the ECS container instances security group ("yes" or "no")         | "yes"              | yes                                      |
| allowed_cidrs                                 | The CIDRs allowed access to containers                                                                                  | ["10.0.0.0/8"]     | if include_default_ingress_rule is "yes" | 
| egress_cidrs                                  | The CIDRs accessible from containers                                                                                    | ["0.0.0.0/0"]      | if include_default_egress_rule is "yes"  | 

Notes:
* By default, the latest available Amazon Linux 2 AMI is used.
* When Amazon Linux 1 AMIs are requested, an additional EBS volume is attached 
  which can be customised using the `cluster_instance_docker_block_device_size`,
  `cluster_instance_docker_block_device_type` and 
  `cluster_instance_docker_block_device_name` variables.
* When a specific AMI is provided via `cluster_instance_amis` (a map of region 
  to AMI ID), only the root block device can be customised, using the 
  `cluster_instance_root_block_device_size` and 
  `cluster_instance_root_block_device_type` variables.
* The user data template with be passed the cluster name as `cluster_name`. If 
  none is supplied, a default will be used.

### Outputs

| Name                      | Description                                                              |
|---------------------------|--------------------------------------------------------------------------|
| cluster_id                | The ID of the created ECS cluster                                        |
| cluster_name              | The name of the created ECS cluster                                      |
| autoscaling_group_name    | The name of the autoscaling group for the ECS container instances        |
| launch_configuration_name | The name of the launch configuration for the ECS container instances     |
| security_group_id         | The ID of the security group associated with the ECS container instances |
| instance_role_arn         | The ARN of the container instance role                                   |
| instance_role_id          | The ID of the container instance role                                    |
| instance_policy_arn       | The ARN of the container instance policy                                 |
| instance_policy_id        | The ID of the container instance policy                                  |
| service_role_arn          | The ARN of the ECS service role                                          |
| service_role_id           | The ID of the ECS service role                                           |
| service_policy_arn        | The ARN of the ECS service policy                                        |
| service_policy_id         | The ID of the ECS service policy                                         |
| log_group                 | The name of the default log group for the cluster                        |

### Required Permissions

* iam:GetPolicy
* iam:GetPolicyVersion
* iam:ListPolicyVersions
* iam:ListEntitiesForPolicy
* iam:CreatePolicy
* iam:DeletePolicy
* iam:GetRole
* iam:PassRole
* iam:CreateRole
* iam:DeleteRole
* iam:ListRolePolicies
* iam:AttachRolePolicy
* iam:DetachRolePolicy
* iam:GetInstanceProfile
* iam:CreateInstanceProfile
* iam:ListInstanceProfilesForRole
* iam:AddRoleToInstanceProfile
* iam:RemoveRoleFromInstanceProfile
* iam:DeleteInstanceProfile
* ec2:DescribeSecurityGroups
* ec2:CreateSecurityGroup
* ec2:DeleteSecurityGroup
* ec2:AuthorizeSecurityGroupIngress
* ec2:AuthorizeSecurityGroupEgress
* ec2:RevokeSecurityGroupEgress
* ec2:ImportKeyPair
* ec2:DescribeKeyPairs
* ec2:DeleteKeyPair
* ec2:CreateTags
* ec2:DescribeImages
* ec2:DescribeNetworkInterfaces
* ecs:DescribeClusters
* ecs:CreateCluster
* ecs:DeleteCluster
* autoscaling:DescribeLaunchConfigurations
* autoscaling:CreateLaunchConfiguration
* autoscaling:DeleteLaunchConfiguration
* autoscaling:DescribeScalingActivities
* autoscaling:DescribeAutoScalingGroups
* autoscaling:CreateAutoScalingGroup
* autoscaling:UpdateAutoScalingGroup
* autoscaling:DeleteAutoScalingGroup
* logs:CreateLogGroup
* logs:DescribeLogGroups
* logs:ListTagsLogGroup
* logs:DeleteLogGroup


Development
-----------

### Machine Requirements

In order for the build to run correctly, a few tools will need to be installed 
on your development machine:

* Ruby (2.3.1)
* Bundler
* git
* git-crypt
* gnupg
* direnv

#### Mac OS X Setup

Installing the required tools is best managed by [homebrew](http://brew.sh).

To install homebrew:

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Then, to install the required tools:

```
# ruby
brew install rbenv
brew install ruby-build
echo 'eval "$(rbenv init - bash)"' >> ~/.bash_profile
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
eval "$(rbenv init -)"
rbenv install 2.3.1
rbenv rehash
rbenv local 2.3.1
gem install bundler

# git, git-crypt, gnupg
brew install git
brew install git-crypt
brew install gnupg

# direnv
brew install direnv
echo "$(direnv hook bash)" >> ~/.bash_profile
echo "$(direnv hook zsh)" >> ~/.zshrc
eval "$(direnv hook $SHELL)"

direnv allow <repository-directory>
```

### Running the build

To provision module infrastructure, run tests and then destroy that 
infrastructure, execute:

```bash
./go
```

To provision the module prerequisites:

```bash
./go deployment:prerequisites:provision[<deployment_identifier>]
```

To provision the module contents:

```bash
./go deployment:harness:provision[<deployment_identifier>]
```

To destroy the module contents:

```bash
./go deployment:harness:destroy[<deployment_identifier>]
```

To destroy the module prerequisites:

```bash
./go deployment:prerequisites:destroy[<deployment_identifier>]
```


### Common Tasks

#### Generating an SSH key pair

To generate an SSH key pair:

```
ssh-keygen -t rsa -b 4096 -C integration-test@example.com -N '' -f config/secrets/keys/bastion/ssh
```

#### Managing CircleCI keys

To encrypt a GPG key for use by CircleCI:

```bash
openssl aes-256-cbc \
  -e \
  -md sha1 \
  -in ./config/secrets/ci/gpg.private \
  -out ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

To check decryption is working correctly:

```bash
openssl aes-256-cbc \
  -d \
  -md sha1 \
  -in ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

Contributing
------------

Bug reports and pull requests are welcome on GitHub at 
https://github.com/tobyclemson/terraform-aws-ecs-cluster. This project is 
intended to be a safe, welcoming space for collaboration, and contributors are 
expected to adhere to the 
[Contributor Covenant](http://contributor-covenant.org) code of conduct.


License
-------

The library is available as open source under the terms of the 
[MIT License](http://opensource.org/licenses/MIT).
