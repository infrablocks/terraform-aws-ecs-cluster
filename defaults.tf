locals {
  # default for cases when `null` value provided, meaning "use default"
  cluster_name = var.cluster_name == "default" ? [] : var.cluster_name
}
