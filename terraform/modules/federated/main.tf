
terraform {
  required_providers {
    konnect = {
      source                = "kong/konnect"
      configuration_aliases = [konnect.global]
    }
  }
}


data "local_file" "resources" {
  filename = "${path.module}/resources.json"
}

locals {
  team            = jsondecode(data.local_file.resources.content)
  resources       = lookup(jsondecode(data.local_file.resources.content), "resources", [])
  control_planes  = [for resource in local.resources : resource if resource.type == "konnect::control_plane"]
  days_to_hours   = 365 * 24 // 1 year
  expiration_date = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
}

# Create a Konnect Gateway Control Plane for each control plane in the resources
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
  for_each = { for cp in konnect_gateway_control_plane.tfcps : cp.name => cp }

  cert             = file("${path.module}/.tls/ca.crt")
  control_plane_id = each.value.id
}


# Create system account for the team
resource "konnect_system_account" "systemaccount" {

  name            = "team-${lookup(local.team, "name", "")}-system-account"
  description     = "System account for team ${lookup(local.team, "name", "")}"
  konnect_managed = false

  provider = konnect.global

}

# Create an access token for the system account
resource "konnect_system_account_access_token" "systemaccountaccesstoken" {
  name       = "tf_sat_${lower(replace(lookup(local.team, "name", ""), " ", "_"))}"
  expires_at = local.expiration_date
  account_id = konnect_system_account.systemaccount.id

  provider = konnect.global

}

# Assign the system accounts to the team
resource "konnect_system_account_team" "systemaccountteam" {
  account_id = konnect_system_account.systemaccount.id
  team_id    = lookup(local.team, "id", "")

  provider = konnect.global
}

# System Account Role Assignments
resource "konnect_system_account_role" "systemaccountroles" {
  for_each = { for idx, cp in konnect_gateway_control_plane.tfcps : idx => cp }

  entity_id = each.value.id

  entity_region    = "eu"
  entity_type_name = "Control Planes"
  role_name        = "Admin"
  account_id       = konnect_system_account.systemaccount.id

  provider = konnect.global
  
}

output "system_account_access_token" {
  value = konnect_system_account_access_token.systemaccountaccesstoken
  sensitive = true
}

output "kong_gateway_control_plane_info" {
  # value = length(konnect_gateway_control_plane.tfcpgroups) > 0 ? konnect_gateway_control_plane.tfcpgroups : konnect_gateway_control_plane.tfcps
  value = konnect_gateway_control_plane.tfcps
}
