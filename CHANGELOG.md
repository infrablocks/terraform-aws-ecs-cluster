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