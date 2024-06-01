
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
  alias      = "global"
  personal_access_token = var.konnect_personal_access_token
  server_url = "https://global.api.konghq.com"
}

data "local_file" "teams" {
  filename = "${path.module}/teams.json"
}

locals {
  teams = jsondecode(data.local_file.teams.content)
  days_to_hours = 365 * 24 // 1 year
  expiration_date = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
}

resource "konnect_gateway_control_plane" "tfcpgroup" {
  name         = "Demo CP Group"
  description  = "This is a demo Control Plane Group"
  cluster_type = "CLUSTER_TYPE_CONTROL_PLANE_GROUP"
  auth_type    = "pki_client_certs"

  proxy_urls = []

  labels = {
    env          = "demo",
    team         = "platform",
    generated_by = "terraform"
  }

}

resource "konnect_gateway_control_plane" "tfcp" {
  count = length(local.teams)

  name         = length(local.teams) > 0 ? "${local.teams[count.index].name} CP" : ""
  description  = length(local.teams) > 0 ? "This is a demo Control Plane for ${local.teams[count.index].name}" : ""
  cluster_type = "CLUSTER_TYPE_HYBRID"
  auth_type    = "pki_client_certs"
  labels = {
    env          = "demo",
    team         = length(local.teams) > 0 ? lower(replace(local.teams[count.index].name, " ", "_")) : "",
    generated_by = "terraform"
  }

  proxy_urls = []
}

resource "konnect_gateway_control_plane_membership" "gatewaycontrolplanemembership" {
  id = konnect_gateway_control_plane.tfcpgroup.id
  members = [
    for cp in konnect_gateway_control_plane.tfcp : {
      id = cp.id
    }
  ]
}

# Add the required data plane certificates to the control plane group
resource "konnect_gateway_data_plane_client_certificate" "demo_ca_cert" {
  cert             = file("../.tls/ca.crt")
  control_plane_id = konnect_gateway_control_plane.tfcpgroup.id
}

# Creat a system account for every team
resource "konnect_system_account" "systemaccounts" {
  count = length(local.teams)

  name            = length(local.teams) > 0 ? "${local.teams[count.index].name} System Account" : ""
  description     = length(local.teams) > 0 ? "Demo System Account for ${local.teams[count.index].name}" : ""
  konnect_managed = false

  provider = konnect.global

}

# Create an access token for every system account
resource "konnect_system_account_access_token" "systemaccountaccesstokens" {
  count = length(konnect_system_account.systemaccounts)

  name       = length(local.teams) > 0 ? "tf_sat_${lower(replace(local.teams[count.index].name, " ", "_"))}" : ""
  # Make expires at 1 month from now
  expires_at = local.expiration_date
  account_id = length(local.teams) > 0 ? konnect_system_account.systemaccounts[count.index].id: ""

  provider = konnect.global

}

# Make system accounts admin of their respective control plane
resource "konnect_system_account_role" "systemaccountroles" {
  count = length(local.teams)

  entity_id        = length(local.teams) > 0 ? konnect_gateway_control_plane.tfcp[count.index].id : ""
  entity_region    = "eu"
  entity_type_name = "Control Planes"
  role_name        = "Admin"
  account_id       = length(local.teams) > 0 ? konnect_system_account.systemaccounts[count.index].id : ""

  provider = konnect.global
}

# Add the system accounts to the respective teams
resource "konnect_system_account_team" "systemaccountteams" {
  count = length(local.teams)
  
  account_id = length(local.teams) > 0 ? konnect_system_account.systemaccounts[count.index].id : ""
  team_id = length(local.teams) > 0 ? local.teams[count.index].id : ""

  provider = konnect.global
}

output "system_account_access_tokens" {
  value = konnect_system_account_access_token.systemaccountaccesstokens
}

output "kong_gateway_control_plane_info" {
  value = konnect_gateway_control_plane.tfcpgroup
}
