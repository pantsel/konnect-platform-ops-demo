resource "konnect_team" "tfteams" {
  for_each = { for team in local.teams : team.name => team }
  name        = each.value.name
  description = each.value.description

  labels = {
    example-label = "example-label"
  }
}

resource "konnect_team_role" "team_roles" {
  for_each = { for team_role in local.team_roles : team_role.unique_key => team_role }
  
  team_id = { for team in konnect_team.tfteams : lower(team.name) => team.id}[each.value.team_name]
  entity_id = each.value.entity_name == "*" ? "*" : {for cp in konnect_gateway_control_plane.tfgatewaycontrolplane : lower(cp.name) => cp.id}[lower(each.value.entity_name)]
  entity_region    = each.value.entity_region
  entity_type_name = each.value.entity_type_name
  role_name        = each.value.role_name

}

resource "konnect_system_account" "systemaccounts" {
  for_each = { for account in local.system_accounts : account.name => account }

  name            = each.value.name
  description     = each.value.description
  konnect_managed = false

  provider = konnect.global

}

resource "konnect_system_account_access_token" "systemaccountaccesstokens" {
  for_each = { for account in konnect_system_account.systemaccounts : account.name => account }

  name       = "npa_${lower(replace(each.value.name, " ", "_"))}"
  expires_at = local.expiration_date
  account_id = each.value.id

  provider = konnect.global

}

resource "konnect_system_account_role" "systemaccountroles" {
  for_each = { for idx, role in local.system_account_roles : idx => role }

  entity_id = each.value.entity_name == "*" ? "*" :{
    for cp in konnect_gateway_control_plane.tfgatewaycontrolplane : lower(cp.name) => cp.id
  }[lower(each.value.entity_name)]

  entity_region    = each.value.entity_region
  entity_type_name = each.value.entity_type_name
  role_name        = each.value.role_name
  account_id       = {
    for account in konnect_system_account.systemaccounts : lower(account.name) => account.id
  }[lower(each.value.account_name)]

  provider = konnect.global
  
}

resource "konnect_system_account_team" "systemaccountteams" {
  for_each = { for idx, team_membership in local.system_account_memberships : idx => team_membership }

  account_id = {
    for account in konnect_system_account.systemaccounts : lower(account.name) => account.id
  }[lower(each.value.system_account_name)]
  
  team_id = { for team in konnect_team.tfteams : lower(team.name) => team.id}[each.value.team_name]
  
  # team_id    = {
  #   for team in local.teams : lower(team.name) => team.id
  # }[lower(each.value.team_name)]

  provider = konnect.global
}

output "system_account_access_tokens" {
  value = konnect_system_account_access_token.systemaccountaccesstokens
  sensitive = true
}