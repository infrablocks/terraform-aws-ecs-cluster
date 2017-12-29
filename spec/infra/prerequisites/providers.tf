provider "aws" {
  region = "${var.region}"
  version = "~> 1.6"
}

provider "null" {
  version = "~> 1.0"
}

provider "template" {
  version = "~> 1.0"
}
