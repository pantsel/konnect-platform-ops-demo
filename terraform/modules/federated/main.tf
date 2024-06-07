
terraform {
  required_providers {
    konnect = {
      source                = "kong/konnect"
      configuration_aliases = [konnect.global]
    }
  }
}


data "local_file" "resources" {
  filename = "../../../environments/${var.environment}/federated/resources.json"
}

locals {
  cert_path       = "../../../environments/${var.environment}/federated/.tls/ca.crt"
  team            = lookup(jsondecode(data.local_file.resources.content), "metadata", {})
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
    generated_by = "terraform"
  })

  proxy_urls = lookup(each.value, "proxy_urls", [])
}

# Add the required data plane certificates to the control planes
resource "konnect_gateway_data_plane_client_certificate" "cacertcp" {
  for_each = { for cp in konnect_gateway_control_plane.tfcps : cp.name => cp }

  cert             = file(local.cert_path)
  control_plane_id = each.value.id
}

# Create system accounts for every control plane
resource "konnect_system_account" "systemaccounts" {
  for_each = { for cp in local.control_planes : cp.name => cp }

  name            = "npa_${local.team.name}_${each.value.name}"
  description     = "System account for team ${local.team.name} and control plane ${each.value.name}"
  konnect_managed = false

  provider = konnect.global

}

# Create an access tokens for the system accounts
resource "konnect_system_account_access_token" "systemaccountaccesstokens" {
  for_each = { for account in konnect_system_account.systemaccounts : account.name => account }

  name       = lower(replace(each.value.name, " ", "_"))
  expires_at = local.expiration_date
  account_id = each.value.id

  provider = konnect.global

}
# Assign the system accounts to the team
resource "konnect_system_account_team" "systemaccountteam" {

  for_each = { for account in konnect_system_account.systemaccounts : account.name => account }

  account_id = each.value.id
  team_id    = lookup(local.team, "id", "")

  provider = konnect.global
}

# System Account Role Assignments
resource "konnect_system_account_role" "systemaccountroles" {
  for_each = { for cp in konnect_gateway_control_plane.tfcps : cp.name => cp }

  entity_id = each.value.id

  entity_region    = lookup(local.team, "region", "")
  entity_type_name = "Control Planes"
  role_name        = "Admin"
  account_id = {
    for account in konnect_system_account.systemaccounts : lower(account.name) => account.id
  }["npa_${lookup(local.team, "name", "")}_${each.value.name}"]


  provider = konnect.global

}

output "system_account_access_tokens" {
  value     = konnect_system_account_access_token.systemaccountaccesstokens
  sensitive = true
}

output "kong_gateway_control_plane_info" {
  # value = length(konnect_gateway_control_plane.tfcpgroups) > 0 ? konnect_gateway_control_plane.tfcpgroups : konnect_gateway_control_plane.tfcps
  value = konnect_gateway_control_plane.tfcps
}
