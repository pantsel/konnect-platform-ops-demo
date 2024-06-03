
terraform {
  backend "s3" {}
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

provider "konnect" {
  personal_access_token = var.konnect_personal_access_token
  server_url            = var.konnect_server_url
}

provider "konnect" {
  alias                 = "global"
  personal_access_token = var.konnect_personal_access_token
  server_url            = "https://global.api.konghq.com"
}

data "local_file" "resources" {
  filename = "${path.module}/resources.json"
}

locals {
  teams           = jsondecode(data.local_file.resources.content).teams
  control_planes  = jsondecode(data.local_file.resources.content).control_planes
  system_accounts = jsondecode(data.local_file.resources.content).system_accounts
  // Flatten the roles structure
  roles = flatten([
    for system_account in local.system_accounts : [
      for role in system_account.roles : {
        account_name    = system_account.name
        entity_type_name = role.entity_type_name
        entity_name      = role.entity_name
        entity_region    = role.entity_region
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
  control_plane_groups = jsondecode(data.local_file.resources.content).control_plane_groups
  days_to_hours        = 365 * 24 // 1 year
  expiration_date      = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
}

resource "konnect_gateway_control_plane" "tfcpgroup" {
  count = length(local.control_plane_groups)

  name         = local.control_plane_groups[count.index].name
  description  = local.control_plane_groups[count.index].description
  cluster_type = "CLUSTER_TYPE_CONTROL_PLANE_GROUP"
  auth_type    = "pki_client_certs"

  proxy_urls = []

  labels = merge(lookup(local.control_plane_groups[count.index], "labels", {}), {
    env          = "demo",
    generated_by = "terraform"
  })

}

# Add the required data plane certificates to the control plane groups
resource "konnect_gateway_data_plane_client_certificate" "cacertcpgroup" {
  count = length(local.control_plane_groups)

  cert             = file("../.tls/ca.crt")
  control_plane_id = konnect_gateway_control_plane.tfcpgroup[count.index].id
}

resource "konnect_gateway_control_plane" "tfcp" {
  count = length(local.control_planes)

  name         = local.control_planes[count.index].name
  description  = local.control_planes[count.index].description
  cluster_type = "CLUSTER_TYPE_HYBRID"
  auth_type    = "pki_client_certs"
  labels = merge(lookup(local.control_planes[count.index], "labels", {}), {
    env          = "demo",
    generated_by = "terraform"
  })

  proxy_urls = []
}

# Add the required data plane certificates to the control planes
resource "konnect_gateway_data_plane_client_certificate" "cacertcp" {
  count = length(konnect_gateway_control_plane.tfcp)

  cert             = file("../.tls/ca.crt")
  control_plane_id = konnect_gateway_control_plane.tfcp[count.index].id
}

resource "konnect_gateway_control_plane_membership" "gatewaycontrolplanemembership" {
  count = length(konnect_gateway_control_plane.tfcpgroup)
  id    = konnect_gateway_control_plane.tfcpgroup[count.index].id
  members = [
    for cp in konnect_gateway_control_plane.tfcp : {
      id = cp.id
    } if contains(local.control_plane_groups[count.index].control_planes, cp.name)
  ]
}


resource "konnect_system_account" "systemaccounts" {
  count = length(local.system_accounts)

  name            = local.system_accounts[count.index].name
  description     = local.system_accounts[count.index].description
  konnect_managed = false

  provider = konnect.global

}

# Create an access token for every system account
resource "konnect_system_account_access_token" "systemaccountaccesstokens" {
  count = length(konnect_system_account.systemaccounts)

  name       = "tf_sat_${lower(replace(konnect_system_account.systemaccounts[count.index].name, " ", "_"))}"
  expires_at = local.expiration_date
  account_id = konnect_system_account.systemaccounts[count.index].id

  provider = konnect.global

}

# System Account Role Assignments
resource "konnect_system_account_role" "systemaccountroles" {
  for_each = { for idx, role in local.roles : idx => role }

  entity_id = {
    for cp in konnect_gateway_control_plane.tfcp : lower(cp.name) => cp.id
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
  count = length(local.team_memberships)

  account_id = {
    for account in konnect_system_account.systemaccounts : lower(account.name) => account.id
  }[lower(local.team_memberships[count.index].system_account_name)]
  team_id    = {
    for team in local.teams : lower(team.name) => team.id
  }[lower(local.team_memberships[count.index].team_name)]

  provider = konnect.global
}

output "system_account_access_tokens" {
  value = konnect_system_account_access_token.systemaccountaccesstokens
}

output "kong_gateway_control_plane_info" {
  value = length(konnect_gateway_control_plane.tfcpgroup) > 0 ? konnect_gateway_control_plane.tfcpgroup : konnect_gateway_control_plane.tfcp
}
