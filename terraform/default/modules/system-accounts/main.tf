terraform {
  required_providers {
    konnect = {
      source                = "kong/konnect"
      version               = "1.0.0"
    }
  }
}

locals {
  days_to_hours   = 365 * 24 // 1 year
  expiration_date = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
}

# ============================================================
# =================== DEMO CP ADMIN SYSTEM ACCOUNT ===========
# ============================================================

resource "konnect_system_account" "sa_demo_cp_admin" {
  name            = "demo_cp_admin"
  description     = "System account for managing the demo control plane"
  konnect_managed = false
  
}

# Assign the system account to the demo team
resource "konnect_system_account_team" "sa_demo_cp_admin_team" {
  account_id = konnect_system_account.sa_demo_cp_admin.id

  team_id = var.teams.demo_team.id
}



# Create an access token for the system account
resource "konnect_system_account_access_token" "sa_demo_cp_admin_token" {

  name       = "sa_demo_cp_admin_token"
  expires_at = local.expiration_date
  account_id = konnect_system_account.sa_demo_cp_admin.id

}

# Store the access token in Vault
resource "vault_kv_secret_v2" "sa_demo_cp_admin_token_secret" {
  mount               = local.kv_mount
  name                = "system_accounts/demo_cp_admin"
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



