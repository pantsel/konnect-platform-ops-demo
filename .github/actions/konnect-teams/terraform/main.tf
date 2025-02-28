terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }

    vault = {
      source = "hashicorp/vault"
      version = "4.4.0"
    }
  }
}

locals {
  metadata = lookup(jsondecode(var.config), "metadata", {})
  teams = [for team in lookup(jsondecode(var.config), "resources", []) : team if lookup(team, "offboarded", false) != true]
  days_to_hours        = 365 * 24 // 1 year
  expiration_date      = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
}

resource "konnect_team" "this" {
  for_each = { for team in local.teams : team.name => team }

  description = lookup(each.value, "description", null)
  labels = merge(lookup(each.value, "labels", {
    "generated_by" = "terraform"
  }))
  name = each.value.name
}

module "vault" {
  for_each = { for team in konnect_team.this : team.name => team }

  source = "./modules/vault"

  team_name = replace(lower(each.value.name), " ", "-")
}

# # Create a team vault mount for the KV version 2 secret engine
# resource "vault_mount" "this" {
#   for_each = { for team in konnect_team.this : team.name => team }

#   path        = "${replace(lower(each.value.name), " ", "-")}-kv"
#   type        = "kv"
#   options     = { version = "2" }
#   description = "Vault mount for the ${each.value.name} team"
# }

# data "vault_auth_backend" "this" {
#   path = "github"
# }

# # Create team vault policies
# resource "vault_policy" "this" {
#   for_each = { for kv in vault_mount.this : kv.path => kv }
#   name = "${each.value.path}-policy"

#   policy = <<EOT
# path "${each.value.path}/data/*" {
#   capabilities = ["read"]
# }

# path "${each.value.path}/metadata/*" {
#   capabilities = ["read"]
# }

# EOT
# }

# # Map policies to teams
# resource "vault_github_team" "this" {
#   for_each = { for team in konnect_team.this : team.name => team }

#   backend  = data.vault_auth_backend.this.id
#   team     = "${replace(lower(each.value.name), " ", "-")}-kv"
#   policies = ["${replace(lower(each.value.name), " ", "-")}-kv-policy"]
# }

### Foreach team, create system accounts
resource "konnect_system_account" "this" {
  for_each = { for team in local.teams : team.name => team }

  name = "sa-${replace(lower(each.value.name), " ", "-")}"
  description = "System account for creating control planes for the ${each.value.name} team"
  
  konnect_managed  = false
}

# Assign the system accounts to the teams
resource "konnect_system_account_team" "this" {
  for_each = { for team in konnect_team.this : team.name => team }

  team_id =  each.value.id

  account_id = {
    for sa in konnect_system_account.this : sa.name => sa.id
  }["sa-${replace(lower(each.value.name), " ", "-")}"]
}

### Add the control plane creator role to every team system account
resource "konnect_system_account_role" "cp_creators" {
  for_each = { for sa in konnect_system_account.this : sa.name => sa }

  entity_id = "*"
  entity_region    = "eu" # Hardcoded for now
  entity_type_name = "Control Planes"
  role_name        = "Creator"
  account_id = each.value.id
}

### Add the api product creator role to every team system account
resource "konnect_system_account_role" "ap_creators" {
  for_each = { for sa in konnect_system_account.this : sa.name => sa }

  entity_id = "*"
  entity_region    = "eu" # Hardcoded for now
  entity_type_name = "API Products"
  role_name        = "Creator"
  account_id = each.value.id
}

# Create an access token for every system account
resource "konnect_system_account_access_token" "this" {
  for_each = { for account in konnect_system_account.this : account.name => account }

  name       = "${each.value.name}-token"
  expires_at = local.expiration_date
  account_id = each.value.id

}

# Store the access tokens in the respective team kvs
resource "vault_kv_secret_v2" "this" {

  for_each = { for sat in konnect_system_account_access_token.this : sat.name => sat }

  mount               = "${replace(replace(each.value.name, "-token", ""), "sa-", "")}-kv"
  name                = "konnect-${replace(each.value.name, "-token", "")}"
  delete_all_versions = true
  data_json = jsonencode(
    {
      token = each.value.token
    }
  )
  custom_metadata {
    max_versions = 5
  }
}