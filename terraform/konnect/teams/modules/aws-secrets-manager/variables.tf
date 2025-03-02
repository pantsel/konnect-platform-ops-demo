variable "team_name" {
  description = "The name of the team"
  type        = string
}

variable "system_account_secret_path" {
  description = "The path to the system account secret"
  type        = string
}

variable "system_account_token" {
    description = "The token for the system account"
    type        = string
}

variable "github_org" {
  description = "The GitHub organization to create teams and repositories in"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}