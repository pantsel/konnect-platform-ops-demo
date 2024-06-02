
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
  teams = jsondecode(data.local_file.resources.content).teams
  // Flatten the roles structure
  roles = flatten([
    for team in local.teams : [
      for role in team.roles : {
        team_name        = team.name
        entity_type_name = role.entity_type_name
        entity_name      = role.entity_name
        entity_region    = role.entity_region
        role_name        = role.role_name
      }
    ]
  ])
  control_planes  = jsondecode(data.local_file.resources.content).control_planes
  control_plane_groups       = jsondecode(data.local_file.resources.content).control_plane_groups
  days_to_hours   = 365 * 24 // 1 year
  expiration_date = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
}

resource "konnect_gateway_control_plane" "tfcpgroup" {
  count = length(local.control_plane_groups)

  name         = local.control_plane_groups[count.index].name
  description  = "This is a demo Control Plane Group"
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
  description  = "This is a demo Control Plane"
  cluster_type = "CLUSTER_TYPE_HYBRID"
  auth_type    = "pki_client_certs"
  labels = {
    env = "demo",
    # team        = lower(replace(local.teams[count.index].name, " ", "_"))
    generated_by = "terraform"
  }

  proxy_urls = []
}

# Add the required data plane certificates to the control planes
resource "konnect_gateway_data_plane_client_certificate" "cacertcp" {
  count = length(konnect_gateway_control_plane.tfcp)

  cert             = file("../.tls/ca.crt")
  control_plane_id = konnect_gateway_control_plane.tfcp[count.index].id
}

resource "konnect_gateway_control_plane_membership" "gatewaycontrolplanemembership" {
  count = length(local.control_plane_groups)
  id    = konnect_gateway_control_plane.tfcpgroup[count.index].id
  members = [
    for cp in konnect_gateway_control_plane.tfcp : {
      id = cp.id
    } if contains(local.control_plane_groups[count.index].control_planes, cp.name)
  ]
}


# Creat a system account for every team
resource "konnect_system_account" "systemaccounts" {
  count = length(local.teams)

  name            = "${local.teams[count.index].name} System Account"
  description     = "Demo System Account for ${local.teams[count.index].name}"
  konnect_managed = false

  provider = konnect.global

}

# Create an access token for every system account
resource "konnect_system_account_access_token" "systemaccountaccesstokens" {
  count = length(konnect_system_account.systemaccounts)

  name       = "tf_sat_${lower(replace(local.teams[count.index].name, " ", "_"))}"
  expires_at = local.expiration_date
  account_id = konnect_system_account.systemaccounts[count.index].id

  provider = konnect.global

}

resource "konnect_system_account_role" "systemaccountroles" {
  for_each = { for idx, role in local.roles : idx => role }

  entity_id = {
    for cp in konnect_gateway_control_plane.tfcp : cp.name => cp.id
  }[each.value.entity_name]

  entity_region    = each.value.entity_region
  entity_type_name = each.value.entity_type_name
  role_name        = each.value.role_name
  account_id = {
    for sa in konnect_system_account.systemaccounts : sa.name => sa.id
  }["${each.value.team_name} System Account"]
  provider = konnect.global
}

# Add the system accounts to the respective teams
resource "konnect_system_account_team" "systemaccountteams" {
  count = length(local.teams)

  account_id = konnect_system_account.systemaccounts[count.index].id
  team_id    = local.teams[count.index].id

  provider = konnect.global
}

output "system_account_access_tokens" {
  value = konnect_system_account_access_token.systemaccountaccesstokens
}

output "kong_gateway_control_plane_info" {
  value = length(konnect_gateway_control_plane.tfcpgroup) > 0 ? konnect_gateway_control_plane.tfcpgroup : konnect_gateway_control_plane.tfcp
}
