terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

locals {
  metadata = lookup(jsondecode(var.config), "metadata", {})
  teams = [for team in lookup(jsondecode(var.config), "resources", []) : team if lookup(team, "offboarded", false) != true]
  sanitized_team_names = { for team in local.teams : team.name => replace(lower(team.name), " ", "-") }
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

### Foreach team, create system accounts
resource "konnect_system_account" "this" {
  for_each = { for team in local.teams : team.name => team }

  name = "sa-${local.sanitized_team_names[each.value.name]}"
  description = "System account for creating control planes for the ${each.value.name} team"
  
  konnect_managed  = false
}

# Assign the system accounts to the teams
resource "konnect_system_account_team" "this" {
  for_each = { for team in konnect_team.this : team.name => team }

  team_id =  each.value.id

  account_id = {
    for sa in konnect_system_account.this : sa.name => sa.id
  }["sa-${local.sanitized_team_names[each.value.name]}"]
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

module "vault" {
  for_each = { for team in konnect_team.this : team.name => team }

  source = "./modules/vault"
 
  team_name = local.sanitized_team_names[each.value.name]
  system_account_secret_path = "sa-${local.sanitized_team_names[each.value.name]}"
  system_account_token = konnect_system_account_access_token.this["sa-${local.sanitized_team_names[each.value.name]}"].token
}
