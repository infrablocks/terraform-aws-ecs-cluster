module "admin" {
  source = "../../"

  admin_user_name = "administrator"
  admin_group_name = "administrators"

  admin_public_gpg_key = filebase64(var.public_gpg_key_path)

  admin_user_password_length = 48
}
