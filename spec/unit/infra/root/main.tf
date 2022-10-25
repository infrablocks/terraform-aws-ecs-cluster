data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "assumable_roles_policy" {
  source = "../../../.."

  policy_name = var.policy_name
  policy_description = var.policy_description
  assumable_roles = var.assumable_roles
}