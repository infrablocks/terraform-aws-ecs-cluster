## 0.2.4 (December 30th, 2017)

BACKWARDS INCOMPATIBILITIES / NOTES:

* The cluster now uses the latest ECS optimised amazon linux image by default.
  This can be overridden using the `cluster_instance_amis` variable.
* The `private_subnet_ids` variable has been renamed to `subnet_ids` as there
  is nothing requiring the subnets to be private
  
IMPROVEMENTS:

* The cluster now uses the latest ECS optimised amazon linux image by default.

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