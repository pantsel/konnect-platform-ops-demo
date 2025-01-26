
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
  cert_path       = ".tls/ca.crt"
  metadata        = lookup(jsondecode(data.local_file.resources.content), "metadata", {})
  resources       = lookup(jsondecode(data.local_file.resources.content), "resources", [])
  control_planes  = [for resource in local.resources : resource if resource.type == "konnect.control_plane"]
  api_products    = [for resource in local.resources : resource if resource.type == "konnect.api_product"]
  days_to_hours   = 365 * 24 // 1 year
  expiration_date = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
  short_names = {
    "Control Planes" = "cp",
    "API Products"   = "ap"
  }
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

module "team" {
  source = "./modules/team"

  name           = title(local.metadata.name)
  description    = lookup(local.metadata, "description", "")
  region         = lookup(local.metadata, "region", "")
  control_planes = module.control_planes.control_planes
  api_products   = module.api_products.api_products
}

module "system_accounts" {
  source = "./modules/system_account"

  for_each = merge(
    { for cp in module.control_planes.control_planes : cp.name => { name = cp.name, id = cp.id, type = "Control Planes" } },
    { for product in module.api_products.api_products : product.name => { name = product.name, id = product.id, type = "API Products" } }
  )

  name             = lower(replace("sa_${each.value.name}_${local.short_names[each.value.type]}_admin", " ", "_"))
  description      = "Admin System account for ${each.value.type} ${each.value.name}"
  entity_id        = each.value.id
  entity_type_name = each.value.type
  role_name        = "Admin"
  expiration_date  = local.expiration_date
  region           = lookup(local.metadata, "region", "")
}

output "system_account_access_tokens" {
  value     = { for k, v in module.system_accounts : k => v.access_token }
  sensitive = true
}
