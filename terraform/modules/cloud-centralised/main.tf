terraform {
  required_providers {
    konnect = {
      source                = "kong/konnect"
      configuration_aliases = [konnect.global]
    }
  }
}

data "local_file" "resources" {
  filename = "/Users/maartenschenkeveld/Lab/kong-cicd/konnect-platform-ops-demo/examples/platformops/centralised/cloud-resources.json"
}

locals {
  resources     = lookup(jsondecode(data.local_file.resources.content), "resources", {
    system_accounts = [],
    teams           = [],
    control_planes  = [],
  })
  teams           = lookup(local.resources, "teams", [])
  control_planes  = lookup(local.resources, "control_planes", [])
  system_accounts = lookup(local.resources, "system_accounts", [])
  system_account_roles = flatten([
    for system_account in local.system_accounts : [
      for role in system_account.roles : {
        account_name    = system_account.name
        entity_type_name = role.entity_type_name
        entity_name      = role.entity_name
        entity_region    = lookup(role, "entity_region", "eu")
        role_name        = role.role_name
      }
    ]
  ])
  team_roles = flatten([
    for team in local.teams : [
      for role in team.roles : {
        team_name    = team.name
        entity_type_name = role.entity_type_name
        entity_name      = role.entity_name
        entity_region    = role.entity_region
        role_name        = role.role_name
        unique_key       = sha256("${team.name}-${role.entity_type_name}-${role.entity_name}-${role.entity_region}-${role.role_name}")
      }
    ]
  ])
  system_account_memberships = flatten([
    for system_account in local.system_accounts : [
      for idx  in range(length(system_account.team_memberships)) : {
        team_name = system_account.team_memberships[idx]
        system_account_name = system_account.name
      }
    ]
  ])
  cloud_gateways = flatten([
    for control_plane in local.control_planes : [
      for cloud_gateway in control_plane.cloud_gateways : {
        name                = cloud_gateway.name
        control_plane_name  = control_plane.name
        region              = cloud_gateway.region
        unique_key          = sha256("${control_plane.name}-${cloud_gateway.name}")
      }
    ]
  ])
  days_to_hours        = 365 * 24 // 1 year
  expiration_date      = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
}