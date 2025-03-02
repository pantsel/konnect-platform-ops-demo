terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
}

resource "github_team" "this" {
  name        = var.team_name
  description = var.team_description
  privacy     = "closed"
}

resource "github_repository" "this" {
  name        = "${var.team_name}-krg"
  description = "${var.team_name} team Resource Governance repository"

  visibility = "public"
  
  template {
    owner = var.github_org
    repository  = "krg-template"
  }
}

resource "github_team_repository" "this" {
  team_id    = github_team.this.id
  repository = github_repository.this.name
  permission = "push"
}