terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }

    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
    minio = {
      source = "aminueza/minio"
      version = "3.3.0"
    }
  }
}

locals {
  metadata             = lookup(jsondecode(var.config), "metadata", {})
  teams                = [for team in lookup(jsondecode(var.config), "resources", []) : team if lookup(team, "offboarded", false) != true]
  sanitized_team_names = { for team in local.teams : team.name => replace(lower(team.name), " ", "-") }
}

resource "konnect_team" "this" {
  for_each = { for team in local.teams : team.name => team }

  description = lookup(each.value, "description", null)
  labels = merge(lookup(each.value, "labels", {
    "generated_by" = "terraform"
  }))
  name = each.value.name
}

module "system-account" {
  for_each = { for team in konnect_team.this : team.name => team }

  source = "./modules/system-account"

  team_name = local.sanitized_team_names[each.value.name]
  team_id   = each.value.id
}

module "vault" {
  for_each = { for team in konnect_team.this : team.name => team }

  source = "./modules/vault"

  team_name                  = local.sanitized_team_names[each.value.name]
  system_account_secret_path = "sa-${local.sanitized_team_names[each.value.name]}"
  system_account_token       = module.system-account[each.value.name].system_account_token
}

module "github" {
  for_each = { for team in konnect_team.this : team.name => team }

  source = "./modules/github"

  team_name        = local.sanitized_team_names[each.value.name]
  team_description = each.value.description
  github_org       = var.github_org
}

# module "minio" {
#   for_each = { for team in konnect_team.this : team.name => team }

#   source = "./modules/minio"

#   team_name = local.sanitized_team_names[each.value.name]
#   github_org = var.github_org
#   repo_name = "${local.sanitized_team_names[each.value.name]}-krg"
# }
