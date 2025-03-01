variable "team_name" {
  description = "The name of the team"
  type        = string
}

variable "github_org" {
  description = "The GitHub organization to create teams and repositories in"
  type        = string
}

variable "repo_name" {
  description = "The name of the repository to assign the policy to"
  type        = string
}