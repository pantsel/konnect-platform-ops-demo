
terraform {
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


data "local_file" "resources" {
  filename = var.resources_file
}

locals {
  cert_path       = ".tls/ca.crt"
  metadata        = lookup(jsondecode(data.local_file.resources.content), "metadata", {})
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
    generated_by = "terraform",
    env          = var.environment
  })

  proxy_urls = lookup(each.value, "proxy_urls", [])
}

# Add the required data plane certificates to the control planes
resource "konnect_gateway_data_plane_client_certificate" "cacertcp" {
  for_each = { for cp in konnect_gateway_control_plane.tfcps : cp.name => cp }

  cert             = file(local.cert_path)
  control_plane_id = each.value.id
}

# Provision the team
resource "konnect_team" "team" {
  name        = title(local.metadata.name)
  description = lookup(local.metadata, "description", "")

  labels = merge(lookup(local.metadata, "labels", {}), {
    generated_by = "terraform",
    env          = var.environment
  })
}

# Give the team viewer access to the control planes
resource "konnect_team_role" "teamroles" {
  for_each = { for cp in konnect_gateway_control_plane.tfcps : cp.name => cp }

  entity_id        = each.value.id
  entity_region    = lookup(local.metadata, "region", "")
  entity_type_name = "Control Planes"
  role_name        = "Viewer"
  team_id          = konnect_team.team.id

}

# Create admin system accounts for every control plane
resource "konnect_system_account" "systemaccounts" {
  for_each = { for cp in local.control_planes : cp.name => cp }

  name            = "sa_${each.value.name}_admin"
  description     = "Admin System account for control plane ${each.value.name}"
  konnect_managed = false
}

# Admin System Account Role Assignments
resource "konnect_system_account_role" "systemaccountroles" {
  for_each = { for cp in konnect_gateway_control_plane.tfcps : cp.name => cp }

  entity_id = each.value.id

  entity_region    = lookup(local.metadata, "region", "")
  entity_type_name = "Control Planes"
  role_name        = "Admin"
  account_id = {
    for account in konnect_system_account.systemaccounts : lower(account.name) => account.id
  }["sa_${each.value.name}_admin"]

}

# Create an access tokens for the system accounts
resource "konnect_system_account_access_token" "systemaccountaccesstokens" {
  for_each = { for account in konnect_system_account.systemaccounts : account.name => account }

  name       = lower(replace(each.value.name, " ", "_"))
  expires_at = local.expiration_date
  account_id = each.value.id

}

# Assign the system accounts to the team
# resource "konnect_system_account_team" "systemaccountteam" {

#   for_each = { for account in konnect_system_account.systemaccounts : account.name => account }

#   account_id = each.value.id
#   team_id    = konnect_team.team.id

# }

output "system_account_access_tokens" {
  value     = konnect_system_account_access_token.systemaccountaccesstokens
  sensitive = true
}
