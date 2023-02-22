## 6.0.0 (February 22th 2023)

BACKWARDS INCOMPATIBILITIES / NOTES:

* This module is now compatible with Terraform 1.1 and higher.
* This module now uses EBS volume encryption by default. This can be disabled
  using `cluster_instance_enable_ebs_volume_encryption = false`.
* In line with Amazon's update of the default root block storage device, the 
  default in this module is now `/dev/xvda`.
* All variables previously using `"yes|no"` have been replaced with
  `true|false`.
* The `allowed_cidrs` variable has been renamed to `default_ingress_cidrs`.
* The `egress_cidrs` variable has been renamed to `default_egress_cidrs`.
* The `cluster_instance_amis` variable has been replaced with the singular
  `cluster_instance_ami`, with default value of `null`.
* The following variables have had their default value replaced from `""` to
  `null`:
  - `cluster_instance_user_data_template`
  - `cluster_instance_iam_policy_contents`
  - `cluster_service_iam_policy_contents`

IMPROVEMENTS:

* This module now uses the nullable feature to simplify variable defaults.

## 5.0.1 (February 2nd 2023)

IMPROVEMENTS:

* added option to specify log retention period for cluster
* added option to disable enhanced instance monitoring (enabled by default)
* added option to specify the path of the root block storage device as AWS
  default has changed from `/dev/sda1` to `/dev/xvda`

## 5.0.0 (December 22nd 2022)

BACKWARDS INCOMPATIBILITIES / NOTES:

* This module is now compatible with Terraform 1.0 and higher.
* In line with Amazon's deprecation and pending removal of support for launch
  configurations, this module now creates a launch template for the autoscaling
  group. As a result, the `launch_configuration_name` output has been replaced
  by the `launch_template_name` and `launch_template_id` outputs. Upon upgrading
  this module, the launch configuration will be destroyed and an equivalent
  launch template will be created and associated with the autoscaling group.
* The unused `launch_configuration_create_before_destroy` variable has been
  removed.

IMPROVEMENTS

* This module no longer requires the template provider.
* This module now allows using the Terraform AWS provider v4.

## 4.2.0 (June 20th 2022)

IMPROVEMENTS:

* The `aws` and `null` provider constraints have been loosened to allow this
  module to be used with the latest versions of each.
* The no longer supported `template` provider has been replaced with native
  terraform configuration language equivalents.

## 4.1.0 (March 19th 2022)

IMPROVEMENTS:

* The `aws_ecs_cluster_capacity_providers` resource is now used to associate
  capacity providers with the created ECS cluster.

## 4.0.0 (May 27th, 2021)

BACKWARDS INCOMPATIBILITIES / NOTES:

* This module is now compatible with Terraform 0.14 and higher.

## 0.2.6 (December 31st, 2017)

IMPROVEMENTS:

* The `associate_public_ip_addresses` variable allows public IPs to be
  associated to ECS container instances. By default its value is `no`.

## 0.2.5 (December 31st, 2017)

IMPROVEMENTS:

* Updated README with correct inputs, outputs and usage.

## 0.2.4 (December 30th, 2017)

BACKWARDS INCOMPATIBILITIES / NOTES:

* The cluster now uses the latest ECS optimised amazon linux image by default.
  This can be overridden using the `cluster_instance_amis` variable.
* The `private_subnet_ids` variable has been renamed to `subnet_ids` as there
  is nothing requiring the subnets to be private
* The `private_network_cidr` variable has been renamed to `allowed_cidrs` and
  its type has changed to list.

IMPROVEMENTS:

* The cluster now uses the latest ECS optimised amazon linux image by default.
* The default security group ingress and egress rules are now optional and
  configurable. A list of CIDRs for both ingress and egress can be specified
  using `allowed_cidrs` and `egress_cidrs` respectively. The default rules
  can be disabled using `include_default_ingress_rule` and
  `include_default_egress_rule`.
* The security group ID is now available via an output named
  `security_group_id` so that additional rules can be added outside of the
  module.

## 0.2.3 (December 29th, 2017)

BACKWARDS INCOMPATIBILITIES / NOTES:

* The configuration directory has changed from `<repo>/src` to `<repo>` to
  satisfy the Terraform standard module structure.

IMPROVEMENTS:

* All variables and outputs now have descriptions to satisfy the Terraform
  standard module structure.

## 0.2.0 (November 3th, 2017)

BACKWARDS INCOMPATIBILITIES / NOTES:

* The IAM roles and policies for instance and service now use randomly
  generated names. The value that was previously used for name can now be found
  in the description.
