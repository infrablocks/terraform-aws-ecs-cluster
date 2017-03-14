Terraform AWS ECS Cluster
=========================

A Terraform module for building an ECS Cluster in AWS.

The ECS cluster requires:
* An existing VPC
* Some existing private subnets
 
The ECS cluster consists of:
* A cluster in ECS
* A launch configuration and auto-scaling group for a cluster of ECS container instances
* An SSH key to connect to the ECS container instances
* A security group for the container instances allowing:
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

Usage
-----

To use the module, include something like the following in your terraform configuration:

```hcl-terraform
module "ecs_cluster" {
  source = "git@github.com:tobyclemson/terraform-aws-ecs-cluster.git//src"
  
  region = "eu-west-2"
  vpc_id = "vpc-fb7dc365"
  private_subnet_ids = "subnet-eb32c271,subnet-64872d1f"
  private_network_cidr = "192.168.0.0/16"
  
  component = "important-component"
  deployment_identifier = "production"
  
  cluster_name = "services"
  cluster_instance_ssh_public_key_path = "~/.ssh/id_rsa"
  cluster_instance_instance_type = "t2.small"
  
  cluster_minimum_size = 2
  cluster_maximum_size = 10
  cluster_desired_capacity = 4
}
```

Executing `terraform get` will fetch the module.

As mentioned above, the ECS cluster deploys into an existing base network. Whilst the 
base network can be created using any mechanism you like, the 
[AWS Base Networking](https://github.com/tobyclemson/terraform-aws-base-networking)
module will create everything you need. See the 
[docs](https://github.com/tobyclemson/terraform-aws-base-networking/blob/master/README.md)
for usage instructions.


### Inputs

| Name                                 | Description                                                   | Default            | Required |
|--------------------------------------|---------------------------------------------------------------|:------------------:|:--------:|
| region                               | The region into which to deploy the VPC                       | -                  | yes      |
| vpc_id                               | The ID of the VPC into which to deploy the cluster            | -                  | yes      |
| private_subnet_ids                   | The IDs of the private subnets for container instances        | -                  | yes      |
| private_network_cidr                 | The CIDR of the private network allowed access to containers  | 10.0.0.0/8         | yes      |
| component                            | The component this cluster will contain                       | -                  | yes      |
| deployment_identifier                | An identifier for this instantiation                          | -                  | yes      |
| cluster_name                         | The name of the cluster to create                             | default            | yes      |
| cluster_instance_ssh_public_key_path | The path to the public key to use for the container instances | -                  | yes      |
| cluster_instance_instance_type       | The instance type of the container instances                  | t2.medium          | yes      |
| cluster_instance_user_data_template  | The contents of a template for container instance user data   |                    | no       |
| cluster_instance_amis                | A map of regions to AMIs for the container instances          | ECS optimised AMIs | yes      |
| cluster_instance_iam_policy_contents | The contents of the cluster instance IAM policy               | see src/policies   | no       |
| cluster_service_iam_policy_contents  | The contents of the cluster service IAM policy                | see src/policies   | no       |
| cluster_minimum_size                 | The minimum size of the ECS cluster                           | 1                  | yes      |
| cluster_maximum_size                 | The maximum size of the ECS cluster                           | 10                 | yes      |
| cluster_desired_capacity             | The desired capacity of the ECS cluster                       | 3                  | yes      |

Notes:
* The user data template with be passed the cluster cluster name as `cluster_name`.
* If none is supplied, a default will be used.

### Outputs

| Name                      | Description                                                          |
|---------------------------|----------------------------------------------------------------------|
| cluster_id                | The ID of the created ECS cluster                                    |
| cluster_name              | The name of the created ECS cluster                                  |
| autoscaling_group_name    | The name of the autoscaling group for the ECS container instances    |
| launch_configuration_name | The name of the launch configuration for the ECS container instances |
| instance_role_arn         | The ARN of the container instance role                               |
| instance_role_id          | The ID of the container instance role                                |
| service_role_arn          | The ARN of the ECS service role                                      |
| service_role_id           | The ID of the ECS service role                                       |
| log_group                 | The name of the default log group for the cluster                    |


Development
-----------

### Machine Requirements

In order for the build to run correctly, a few tools will need to be installed on your
development machine:

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

To provision module infrastructure, run tests and then destroy that infrastructure,
execute:

```bash
./go
```

To provision the module test contents:

```bash
./go provision:aws[<deployment_identifier>]
```

To destroy the module test contents:

```bash
./go destroy:aws[<deployment_identifier>]
```

### Common Tasks

To generate an SSH key pair:

```
ssh-keygen -t rsa -b 4096 -C integration-test@example.com -N '' -f config/secrets/keys/bastion/ssh
```

Contributing
------------

Bug reports and pull requests are welcome on GitHub at https://github.com/tobyclemson/terraform-aws-ecs-cluster. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to 
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


License
-------

The library is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
