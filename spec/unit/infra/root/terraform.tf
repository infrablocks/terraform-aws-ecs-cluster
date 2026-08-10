terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.0"
    }
  }
}
