
terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

data "local_file" "resources" {
  filename = var.resources_file
}

locals {
  cert_path      = ".tls/ca.crt"
  metadata       = lookup(jsondecode(data.local_file.resources.content), "metadata", {})
  resources      = lookup(jsondecode(data.local_file.resources.content), "resources", [])
  control_planes = [for resource in local.resources : resource if resource.type == "konnect.control_plane"]
  api_products   = [for resource in local.resources : resource if resource.type == "konnect.api_product"]
}

module "control_planes" {
  source         = "./modules/control-planes"
  environment    = var.environment
  metadata       = local.metadata
  control_planes = local.control_planes
  cacert         = var.cacert
}

module "api_products" {
  source       = "./modules/api-products"
  environment  = var.environment
  metadata     = local.metadata
  api_products = local.api_products
}

module "teams" {
  source         = "./modules/teams"
  environment    = var.environment
  control_planes = module.control_planes.control_planes
  api_products   = module.api_products.api_products
  metadata       = local.metadata
}

module "system_accounts" {
  source         = "./modules/system-accounts"
  environment    = var.environment
  control_planes = module.control_planes.control_planes
  api_products   = module.api_products.api_products
  metadata       = local.metadata
}



output "system_account_access_tokens" {
  value     = module.system_accounts.system_account_access_tokens
  sensitive = true
}
