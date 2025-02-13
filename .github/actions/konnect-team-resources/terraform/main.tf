
terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

locals {
  metadata        = lookup(jsondecode(var.config), "metadata", {})
  resources       = lookup(jsondecode(var.config), "resources", [])
  team            = jsondecode(var.team)
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
  source = "./modules/control_plane"

  for_each = { for cp in local.control_planes : cp.name => cp }

  name         = each.value.name
  description  = each.value.description
  labels       = lookup(each.value, "labels", {})
  cluster_type = lookup(each.value, "cluster_type", "CLUSTER_TYPE_HYBRID")
  auth_type    = lookup(each.value, "auth_type", "pki_client_certs")
  cacert       = var.cacert
}

module "vaults" {
  source = "./modules/vault"

  for_each = { for k, v in module.control_planes : v.control_plane.name => {
    name = v.control_plane.name, id = v.control_plane.id
    type = "Control Planes"
  } }

  control_plane_name = lower(replace(each.value.name, " ", "-"))
  control_plane_id   = each.value.id
}


module "api_products" {
  source = "./modules/api_product"

  for_each = { for product in local.api_products : product.name => product }

  name          = each.value.name
  description   = each.value.description
  labels        = lookup(each.value, "labels", {})
  public_labels = lookup(each.value, "public_labels", {})
}

module "team_role" {
  source = "./modules/team_role"

  team           = {
    id   = lookup(local.team, "id", "")
    name = lookup(local.team, "name", "")
  }
  region         = lookup(local.metadata, "region", "")
  control_planes = [for k, v in module.control_planes : v.control_plane]
  api_products   = [for k, v in module.api_products : v.api_product]
}

module "system_accounts" {
  source = "./modules/system_account"

  for_each = merge(
    { for k, v in module.control_planes : v.control_plane.name => {
      name = v.control_plane.name, id = v.control_plane.id
      type = "Control Planes"
    } },

    { for k, v in module.api_products : v.api_product.name => {
      name = v.api_product.name, id = v.api_product.id
      type = "API Products"
    } }
  )

  name             = lower(replace("sa-${each.value.name}-${local.short_names[each.value.type]}-admin", " ", "-"))
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
