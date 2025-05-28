terraform {
  required_providers {
    konnect-beta = {
      source = "kong/konnect-beta"
    }
    konnect = {
      source = "kong/konnect"
    }
  }
}

locals {
  metadata                     = lookup(jsondecode(var.config), "metadata", {})
  resources                    = lookup(jsondecode(var.config), "resources", [])
  team                         = jsondecode(var.team)
  control_planes               = [for resource in local.resources : resource if resource.type == "konnect.control_plane"]
  api_products                 = [for resource in local.resources : resource if resource.type == "konnect.api_product"]
  apis                         = [for resource in local.resources : resource if resource.type == "konnect.api"]
  api_documents                = [for resource in local.resources : resource if resource.type == "konnect.api_document"]
  api_specifications           = [for resource in local.resources : resource if resource.type == "konnect.api_specification"]
  api_implementations          = [for resource in local.resources : resource if resource.type == "konnect.api_implementation"]
  api_publications             = [for resource in local.resources : resource if resource.type == "konnect.api_publication"]
  cloud_gateway_configurations = [for resource in local.resources : resource if resource.type == "konnect.cloud_gateway_configuration"]
  cloud_gateway_networks       = [for resource in local.resources : resource if resource.type == "konnect.cloud_gateway_network"]
  application_auth_strategys   = [for resource in local.resources : resource if resource.type == "konnect.application_auth_strategy"]
  developer_portals            = [for resource in local.resources : resource if resource.type == "konnect.developer_portal"]
  portal_auths                 = [for resource in local.resources : resource if resource.type == "konnect.portal_auth"]
  portal_custom_domains        = [for resource in local.resources : resource if resource.type == "konnect.portal_custom_domain"]
  portal_teams                 = [for resource in local.resources : resource if resource.type == "konnect.portal_team"]
  portal_customizations        = [for resource in local.resources : resource if resource.type == "konnect.portal_customization"]
  portal_pages                 = [for resource in local.resources : resource if resource.type == "konnect.portal_page"]
  portal_snippets              = [for resource in local.resources : resource if resource.type == "konnect.portal_snippet"]
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
  cloud_vendor       = each.value.cloud_vendor
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

module "developer_portals" {
  source = "./modules/developer_portal"

  for_each = { for dp in local.developer_portals : dp.name => dp }

  name                      = each.value.name
  authentication_enabled    = each.value.authentication_enabled
  auto_approve_applications = each.value.auto_approve_applications
  auto_approve_developers   = each.value.auto_approve_developers
  default_api_visibility    = each.value.default_api_visibility
  // find the application_auth_strategy id from the application_auth_strategy module based on its name
  default_application_auth_strategy_id = module.application_auth_strategy[each.value.default_application_auth_strategy_name].id
  default_page_visibility              = each.value.default_page_visibility
  description                          = each.value.description
  display_name                         = each.value.display_name
  force_destroy                        = each.value.force_destroy
  labels                               = each.value.labels
  rbac_enabled                         = each.value.rbac_enabled
}

module "portal_auths" {
  source = "./modules/portal_auth"

  for_each = { for pa in local.portal_auths : pa.portal_name => pa }

  portal_id                 = module.developer_portals[each.value.portal_name].id
  basic_auth_enabled        = lookup(each.value, "basic_auth_enabled", null)
  idp_mapping_enabled       = lookup(each.value, "idp_mapping_enabled", null)
  konnect_mapping_enabled   = lookup(each.value, "konnect_mapping_enabled", null)
  oidc_auth_enabled         = lookup(each.value, "oidc_auth_enabled", null)
  oidc_claim_mappings       = lookup(each.value, "oidc_claim_mappings", null)
  oidc_client_id            = lookup(each.value, "oidc_client_id", null)
  oidc_client_secret        = lookup(each.value, "oidc_client_secret", null)
  oidc_issuer               = lookup(each.value, "oidc_issuer", null)
  oidc_scopes               = lookup(each.value, "oidc_scopes", null)
  oidc_team_mapping_enabled = lookup(each.value, "oidc_team_mapping_enabled", null)
  saml_auth_enabled         = lookup(each.value, "saml_auth_enabled", null)
}

module "portal_custom_domains" {
  source = "./modules/portal_custom_domain"

  for_each = { for pcd in local.portal_custom_domains : "${pcd.portal_name}-${pcd.hostname}" => pcd }

  enabled   = each.value.enabled
  hostname  = each.value.hostname
  portal_id = module.developer_portals[each.value.portal_name].id
  ssl       = each.value.ssl
}

module "portal_teams" {
  source = "./modules/portal_team"

  for_each = { for pt in local.portal_teams : "${pt.portal_name}-${pt.name}" => pt }

  name        = each.value.name
  portal_id   = module.developer_portals[each.value.portal_name].id
  description = lookup(each.value, "description", null)
}

module "portal_customizations" {
  source = "./modules/portal_customization"

  for_each = { for pc in local.portal_customizations : pc.portal_name => pc }

  portal_id     = module.developer_portals[each.value.portal_name].id
  css           = lookup(each.value, "css", null)
  js            = lookup(each.value, "js", null)
  layout        = lookup(each.value, "layout", null)
  menu          = lookup(each.value, "menu", null)
  robots        = lookup(each.value, "robots", null)
  spec_renderer = lookup(each.value, "spec_renderer", null)
  theme         = lookup(each.value, "theme", null)
}

module "portal_pages" {
  source = "./modules/portal_page"

  for_each = { for pp in local.portal_pages : "${pp.portal_name}-${pp.slug}" => pp }

  content        = each.value.content
  portal_id      = module.developer_portals[each.value.portal_name].id
  slug           = each.value.slug
  description    = lookup(each.value, "description", null)
  parent_page_id = lookup(each.value, "parent_page_id", null)
  status         = lookup(each.value, "status", "published")
  title          = lookup(each.value, "title", null)
  visibility     = lookup(each.value, "visibility", "private")
}

module "portal_snippets" {
  source = "./modules/portal_snippet"

  for_each = { for ps in local.portal_snippets : "${ps.portal_name}-${ps.name}" => ps }

  content     = each.value.content
  name        = each.value.name
  portal_id   = module.developer_portals[each.value.portal_name].id
  description = lookup(each.value, "description", null)
  status      = lookup(each.value, "status", "published")
  title       = lookup(each.value, "title", null)
  visibility  = lookup(each.value, "visibility", "private")
}

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

module "apis" {
  source = "./modules/api"

  for_each = { for api in local.apis : "${api.name}-${lookup(api, "version", "")}" => api }

  name         = each.value.name
  deprecated   = lookup(each.value, "deprecated", false)
  description  = lookup(each.value, "description", null)
  labels       = lookup(each.value, "labels", {})
  slug         = lookup(each.value, "slug", null)
  spec_content = lookup(each.value, "spec_content", null)
  api_version  = lookup(each.value, "version", null)
}

module "api_documents" {
  source = "./modules/api_document"

  for_each = { for doc in local.api_documents : "${doc.api_name}-${doc.slug}" => doc }

  api_id             = module.apis["${each.value.api_name}-${lookup(each.value, "api_version", "")}"].id
  content            = each.value.content
  labels             = lookup(each.value, "labels", {})
  parent_document_id = lookup(each.value, "parent_document_id", null)
  slug               = each.value.slug
  status             = lookup(each.value, "status", "unpublished")
  title              = lookup(each.value, "title", null)
}

module "api_specifications" {
  source = "./modules/api_specification"

  for_each = { for spec in local.api_specifications : "${spec.api_name}-${lookup(spec, "api_version", "")}" => spec }

  api_id  = module.apis["${each.value.api_name}-${lookup(each.value, "api_version", "")}"].id
  content = each.value.content
  type    = lookup(each.value, "spec_type", null)
}

module "api_implementations" {
  source = "./modules/api_implementation"

  for_each = { for impl in local.api_implementations : "${impl.api_name}-${impl.service.control_plane_name}" => impl }

  api_id = module.apis["${each.value.api_name}-${lookup(each.value, "api_version", "")}"].id
  service = {
    control_plane_id = module.control_planes[each.value.service.control_plane_name].control_plane.id
    id               = each.value.service.id
  }
}

module "api_publications" {
  source = "./modules/api_publication"

  for_each = { for pub in local.api_publications : "${pub.api_name}-${pub.portal_name}" => pub }

  api_id                     = module.apis["${each.value.api_name}-${lookup(each.value, "api_version", "")}"].id
  portal_id                  = module.developer_portals[each.value.portal_name].id
  auth_strategy_ids          = lookup(each.value, "auth_strategy_ids", null) != null ? [for name in each.value.auth_strategy_ids : module.application_auth_strategy[name].id] : null
  auto_approve_registrations = lookup(each.value, "auto_approve_registrations", null)
  visibility                 = lookup(each.value, "visibility", "private")
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
