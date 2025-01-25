terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

locals {
  days_to_hours   = 365 * 24 // 1 year
  expiration_date = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
}


# Create admin system accounts for every control plane
resource "konnect_system_account" "systemaccounts" {
  for_each = { for cp in var.control_planes : cp.name => cp }

  name            = "sa_${each.value.name}_admin"
  description     = "Admin System account for control plane ${each.value.name}"
  konnect_managed = false
}

# Admin System Account Role Assignments
resource "konnect_system_account_role" "systemaccountroles" {
  for_each = { for cp in var.control_planes : cp.name => cp }

  entity_id = each.value.id

  entity_region    = lookup(var.metadata, "region", "")
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

output "system_account_access_tokens" {
  value     = konnect_system_account_access_token.systemaccountaccesstokens
  sensitive = true
}
