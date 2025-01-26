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
resource "konnect_system_account" "sas" {
  for_each = { for cp in var.control_planes : cp.name => cp }

  name            = lower(replace("sa_${each.value.name}_cp_admin", " ", "_"))
  description     = "Admin System account for control plane ${each.value.name}"
  konnect_managed = false
}

# Admin System Account Role Assignments
resource "konnect_system_account_role" "sa_roles" {
  for_each = { for cp in var.control_planes : cp.name => cp }

  entity_id = each.value.id

  entity_region    = lookup(var.metadata, "region", "")
  entity_type_name = "Control Planes"
  role_name        = "Admin"
  account_id = {
    for account in konnect_system_account.sas : lower(account.name) => account.id
  }[lower(replace("sa_${each.value.name}_cp_admin", " ", "_"))]

}

# Create an access tokens for the system accounts
resource "konnect_system_account_access_token" "sa_tkns" {
  for_each = { for account in konnect_system_account.sas : account.name => account }

  name       = each.value.name
  expires_at = local.expiration_date
  account_id = each.value.id
}


# API Product System Accounts
resource "konnect_system_account" "product_sas" {
  for_each = { for product in var.api_products : product.name => product }

  name            = lower(replace("sa_${each.value.name}_ap_admin", " ", "_"))
  description     = "Admin System account for API Product ${each.value.name}"
  konnect_managed = false
}

# API Product Admin Role Assignments
resource "konnect_system_account_role" "product_sa_roles" {
  for_each = { for product in var.api_products : product.name => product }

  entity_id = each.value.id

  entity_region    = lookup(var.metadata, "region", "")
  entity_type_name = "API Products"
  role_name        = "Admin"
  account_id = {
    for account in konnect_system_account.product_sas : lower(account.name) => account.id
  }[lower(replace("sa_${each.value.name}_ap_admin", " ", "_"))]

}

# API Product System Account Access Tokens
resource "konnect_system_account_access_token" "product_sa_tkns" {
  for_each = { for account in konnect_system_account.product_sas : account.name => account }

  name       = each.value.name
  expires_at = local.expiration_date
  account_id = each.value.id
}

output "system_account_access_tokens" {
  value     = merge(konnect_system_account_access_token.sa_tkns, konnect_system_account_access_token.product_sa_tkns)
  sensitive = true
}
