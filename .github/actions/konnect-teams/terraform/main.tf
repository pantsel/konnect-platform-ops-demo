terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }

    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
}

locals {
  metadata             = lookup(jsondecode(var.config), "metadata", {})
  teams                = [for team in lookup(jsondecode(var.config), "resources", []) : team if lookup(team, "offboarded", false) != true]
  sanitized_team_names = { for team in local.teams : team.name => replace(lower(team.name), " ", "-") }
  camelized_team_names = { for team in local.teams : team.name => replace(title(lower(team.name)), " ", "") }
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

module "aws-secrets-manager" {
  for_each = { for team in konnect_team.this : team.name => team }

  source = "./modules/aws-secrets-manager"

  team_name = local.sanitized_team_names[each.value.name]
  system_account_secret_path = "sa-${local.sanitized_team_names[each.value.name]}"
  system_account_token       = module.system-account[each.value.name].system_account_token
  github_org = var.github_org
  aws_account_id = var.aws_account_id
  aws_region = var.aws_region
}
