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

# ============================================================
# =================== GLOBAL CP ADMIN SYSTEM ACCOUNT =========
# ============================================================

resource "konnect_system_account" "global_cp_admin" {
  name            = "sa-global-cp-admin"
  description     = "System account for managing the global control plane"
  konnect_managed = false

}

resource "konnect_system_account_role" "global_cp_admin_role" {
  account_id       = konnect_system_account.global_cp_admin.id
  entity_id        = "*"
  entity_region    = var.konnect_region
  entity_type_name = "Control Planes"
  role_name        = "Admin"
}

# Create an access token for the system account
resource "konnect_system_account_access_token" "global_cp_admin_token" {

  name       = "sa-global-cp-admin"
  expires_at = local.expiration_date
  account_id = konnect_system_account.global_cp_admin.id

}

# Store the access token in Vault
resource "vault_kv_secret_v2" "global_cp_admin_token_secret" {
  mount               = local.kv_mount
  name                = "system-accounts/sa-global-cp-admin"
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode(
    {
      token = konnect_system_account_access_token.global_cp_admin_token.token,
    }
  )

  custom_metadata {
    max_versions = 5
  }
}



# ============================================================
# =================== DEMO CP ADMIN SYSTEM ACCOUNT ===========
# ============================================================

resource "konnect_system_account" "sa_demo_cp_admin" {
  name            = "sa-demo-cp-admin"
  description     = "System account for managing the demo control plane"
  konnect_managed = false

}

resource "konnect_system_account_role" "sa_demo_cp_role" {
  account_id       = konnect_system_account.sa_demo_cp_admin.id
  entity_id        = var.control_planes.demo_cp.id
  entity_region    = var.konnect_region
  entity_type_name = "Control Planes"
  role_name        = "Admin"
}

# Create an access token for the system account
resource "konnect_system_account_access_token" "sa_demo_cp_admin_token" {

  name       = "sa-demo-cp-admin"
  expires_at = local.expiration_date
  account_id = konnect_system_account.sa_demo_cp_admin.id

}

# Store the access token in Vault
resource "vault_kv_secret_v2" "sa_demo_cp_admin_token_secret" {
  mount               = local.kv_mount
  name                = "system-accounts/sa-demo-cp-admin"
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode(
    {
      token = konnect_system_account_access_token.sa_demo_cp_admin_token.token,
    }
  )

  custom_metadata {
    max_versions = 5
  }
}



