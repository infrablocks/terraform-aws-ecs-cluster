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
  satisfy the terraform standard module structure.
  
IMPROVEMENTS:

* All variables and outputs now have descriptions to satisfy the terraform
  standard module structure. 

## 0.2.0 (November 3th, 2017) 

BACKWARDS INCOMPATIBILITIES / NOTES:

* The IAM roles and policies for instance and service now use randomly 
  generated names. The value that was previously used for name can now be found 
  in the description.