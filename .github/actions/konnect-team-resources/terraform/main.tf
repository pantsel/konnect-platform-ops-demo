terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "2.7.4"
    }
  }
}

locals {
  metadata                     = lookup(jsondecode(var.config), "metadata", {})
  resources                    = lookup(jsondecode(var.config), "resources", [])
  team                         = jsondecode(var.team)
  control_planes               = [for resource in local.resources : resource if resource.type == "konnect.control_plane"]
  api_products                 = [for resource in local.resources : resource if resource.type == "konnect.api_product"]
  cloud_gateway_configurations = [for resource in local.resources : resource if resource.type == "konnect.cloud_gateway_configuration"]
  cloud_gateway_networks       = [for resource in local.resources : resource if resource.type == "konnect.cloud_gateway_network"]
  application_auth_strategys   = [for resource in local.resources : resource if resource.type == "konnect.application_auth_strategy"]
  developer_portals            = [for resource in local.resources : resource if resource.type == "konnect.developer_portal"]
  days_to_hours                = 365 * 24 // 1 year
  expiration_date              = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
  short_names = {
    "Control Planes" = "cp",
    "API Products"   = "ap"
  }
}

module "control_planes" {
  source = "./modules/control_plane"

  for_each = { for cp in local.control_planes : cp.name => cp }

  name          = each.value.name
  description   = each.value.description
  cloud_gateway = lookup(each.value, "cloud_gateway", false)
  labels        = lookup(each.value, "labels", {})
  cluster_type  = lookup(each.value, "cluster_type", "CLUSTER_TYPE_HYBRID")
  auth_type     = lookup(each.value, "auth_type", "pki_client_certs")
  cacert        = var.cacert
}

module "control_plane_membership" {
  source = "./modules/control_plane_membership"

  // for each control plane in the control_planes module with
  // a cluster_type of CLUSTER_TYPE_CONTROL_PLANE_GROUP
  for_each = { for k, v in module.control_planes : v.control_plane.name => v.control_plane if v.control_plane.cluster_type == "CLUSTER_TYPE_CONTROL_PLANE_GROUP" }

  id = each.value.id
  members = [
    for member_name in lookup(
      { for cp in local.control_planes : cp.name => lookup(cp, "members", []) if lookup(cp, "cluster_type", "") == "CLUSTER_TYPE_CONTROL_PLANE_GROUP" },
      each.key,
      []
      ) : {
      id = module.control_planes[
      member_name].control_plane.id
    }
  ]
}

module "cloud_gateway_network" {
  source = "./modules/cloud_gateway_network"

  for_each = { for cgwn in local.cloud_gateway_networks : cgwn.name => cgwn }

  name               = each.value.name
  cidr_block         = each.value.cidr_block
  region             = each.value.region
  availability_zones = each.value.availability_zones
}

module "cloud_gateway_configuration" {
  source = "./modules/cloud_gateway_configuration"

  for_each = {
    for idx, cgc in tolist(local.cloud_gateway_configurations) :
    idx => cgc
  }

  control_plane_geo = each.value.control_plane_geo
  api_access        = each.value.api_access
  // find the control plane id from the control_planes module based on its name
  control_plane_id = module.control_planes[each.value.control_plane_name].control_plane.id
  // dataplane_groups is a list of objects. In every object, there is a cloud_gateway_network_id
  // that has to be resolved based on the variable cloud_gateway_network_name 
  dataplane_groups = [
    for dg in each.value.dataplane_groups : {
      provider                 = dg.provider
      region                   = dg.region
      autoscale                = dg.autoscale
      cloud_gateway_network_id = module.cloud_gateway_network[dg.cloud_gateway_network_name].cloud_gateway_network.id
    }
  ]
  gateway_version = each.value.version
}

module "application_auth_strategy" {
  source = "./modules/application_auth_strategy"

  for_each = { for auth_strategy in local.application_auth_strategys : auth_strategy.name => auth_strategy }

  key_auth       = lookup(each.value, "key_auth", null)
  openid_connect = lookup(each.value, "openid_connect", null)
}

# module "developer_portals" {
#   source = "./modules/developer_portal"

#   for_each = { for dp in local.developer_portals : dp.name => dp }

#   name                                 = each.value.name
#   authentication_enabled               = each.value.authentication_enabled
#   auto_approve_applications            = each.value.auto_approve_applications
#   auto_approve_developers              = each.value.auto_approve_developers
#   default_api_visibility               = each.value.default_api_visibility
#   // find the application_auth_strategy id from the application_auth_strategy module based on its name
#   default_application_auth_strategy_id = module.application_auth_strategy[each.value.default_application_auth_strategy_name].application_auth_strategy.id
#   default_page_visibility              = each.value.default_page_visibility
#   description                          = each.value.description
#   display_name                         = each.value.display_name
#   force_destroy                        = each.value.force_destroy
#   labels                               = each.value.labels
#   rbac_enabled                         = each.value.rbac_enabled
# }

module "vaults" {
  source = "./modules/vault"

  for_each = { for k, v in module.control_planes : v.control_plane.name => {
    name = v.control_plane.name, id = v.control_plane.id
    type = "Control Planes"
  } if v.control_plane.cluster_type != "CLUSTER_TYPE_CONTROL_PLANE_GROUP" }

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

  team = {
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
