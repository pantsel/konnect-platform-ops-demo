
terraform {
  required_providers {
    konnect = {
      source                = "kong/konnect"
      configuration_aliases = [konnect.global]
    }
  }
}
data "local_file" "resources" {
  # filename = "../../../environments/${var.environment}/centralised/resources.json"
  filename = var.resources_file
}

locals {
  cert_path = "../../../environments/${var.environment}/centralised/.tls/ca.crt"
  resources     = lookup(jsondecode(data.local_file.resources.content), "resources", {
    system_accounts = [],
    teams           = [],
    control_planes  = [],
    control_plane_groups = []
  })
  teams           = lookup(local.resources, "teams", [])
  control_planes  = lookup(local.resources, "control_planes", [])
  system_accounts = lookup(local.resources, "system_accounts", [])
  // Flatten the roles structure
  roles = flatten([
    for system_account in local.system_accounts : [
      for role in system_account.roles : {
        account_name    = system_account.name
        entity_type_name = role.entity_type_name
        entity_name      = role.entity_name
        entity_region    = lookup(role, "entity_region", "eu")
        role_name        = role.role_name
      }
    ]
  ])
  // Flatten system_accounts.team_memberships structure
  team_memberships = flatten([
    for system_account in local.system_accounts : [
      for idx  in range(length(system_account.team_memberships)) : {
        team_name = system_account.team_memberships[idx]
        system_account_name = system_account.name
      }
    ]
  ])
  control_plane_groups = lookup(local.resources, "control_plane_groups", [])
  days_to_hours        = 365 * 24 // 1 year
  expiration_date      = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
}

# Provision the teams
resource "konnect_team" "teams" {
  for_each = { for team in local.teams : team.name => team }
  name        = each.value.name
  description = each.value.description

  labels = merge(lookup(each.value, "labels", {}), {
    generated_by = "terraform"
  })
}

# Provision the control plane groups
resource "konnect_gateway_control_plane" "tfcpgroups" {
  for_each = { for group in local.control_plane_groups : group.name => group }

  name         = each.value.name
  description  = each.value.description
  cluster_type = "CLUSTER_TYPE_CONTROL_PLANE_GROUP"
  auth_type    = lookup(each.value, "auth_type", "pki_client_certs")

  proxy_urls = []

  labels = merge(lookup( each.value.labels , "labels", {}), {
    env          = "demo",
    generated_by = "terraform"
  })

}

# Add the required data plane certificates to the control plane groups
resource "konnect_gateway_data_plane_client_certificate" "cacertcpgroup" {
  for_each = { for group in konnect_gateway_control_plane.tfcpgroups : group.name => group }

  cert             = file(local.cert_path)
  control_plane_id = each.value.id
}

# Provision the control planes
resource "konnect_gateway_control_plane" "tfcps" {
  for_each = { for cp in local.control_planes : cp.name => cp }

  name         = each.value.name
  description  = each.value.description
  cluster_type = lookup(each.value, "cluster_type", "CLUSTER_TYPE_HYBRID")
  auth_type    = lookup(each.value, "auth_type", "pki_client_certs")
  labels = merge(lookup(each.value, "labels", {}), {
    env          = "demo",
    generated_by = "terraform"
  })

  proxy_urls = lookup(each.value, "proxy_urls", [])
}

# Add the required data plane certificates to the control planes
resource "konnect_gateway_data_plane_client_certificate" "cacertcp" {
  for_each = { for cp in konnect_gateway_control_plane.tfcps : cp.name => cp}

  cert             = file(local.cert_path)
  control_plane_id = each.value.id
}

# Add the respective control planes to the control plane groups
resource "konnect_gateway_control_plane_membership" "gatewaycontrolplanemembership" {
  for_each = { for group in local.control_plane_groups : group.name => group }
  id    = {
    for cp in konnect_gateway_control_plane.tfcpgroups : cp.name => cp.id
  }[each.value.name]
  members = [
    for cp in konnect_gateway_control_plane.tfcps : {
      id = cp.id
    } if contains(each.value.members, cp.name)
  ]
}

# Provision system accounts
resource "konnect_system_account" "systemaccounts" {
  for_each = { for account in local.system_accounts : account.name => account }

  name            = each.value.name
  description     = each.value.description
  konnect_managed = false

  provider = konnect.global

}

# Create an access token for every system account
resource "konnect_system_account_access_token" "systemaccountaccesstokens" {
  for_each = { for account in konnect_system_account.systemaccounts : account.name => account }

  name       = "npa_${lower(replace(each.value.name, " ", "_"))}"
  expires_at = local.expiration_date
  account_id = each.value.id

  provider = konnect.global

}

# System Account Role Assignments
resource "konnect_system_account_role" "systemaccountroles" {
  for_each = { for idx, role in local.roles : idx => role }

  entity_id = each.value.entity_name == "*" ? "*" :{
    for cp in konnect_gateway_control_plane.tfcps : lower(cp.name) => cp.id
  }[lower(each.value.entity_name)]

  entity_region    = each.value.entity_region
  entity_type_name = each.value.entity_type_name
  role_name        = each.value.role_name
  account_id       = {
    for account in konnect_system_account.systemaccounts : lower(account.name) => account.id
  }[lower(each.value.account_name)]

  provider = konnect.global
  
}

# Assign the system accounts to the respective teams
resource "konnect_system_account_team" "systemaccountteams" {
  for_each = { for idx, team_membership in local.team_memberships : idx => team_membership }

  account_id = {
    for account in konnect_system_account.systemaccounts : lower(account.name) => account.id
  }[lower(each.value.system_account_name)]
  team_id    = {
    for team in konnect_team.teams : lower(team.name) => team.id
  }[lower(each.value.team_name)]

  provider = konnect.global
}

output "system_account_access_tokens" {
  value = konnect_system_account_access_token.systemaccountaccesstokens
  sensitive = true
}

output "kong_gateway_control_plane_info" {
  value = length(konnect_gateway_control_plane.tfcpgroups) > 0 ? konnect_gateway_control_plane.tfcpgroups : konnect_gateway_control_plane.tfcps
}
