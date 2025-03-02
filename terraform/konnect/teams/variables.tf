// variables.tf

variable "konnect_personal_access_token" {
  description = "The Konnect Personal Access Token to use for API requests"
  type        = string
}

variable "konnect_server_url" {
  description = "The URL of the Konnect server to connect to"
  type        = string
}

variable "config" {
  description = "Configuration for the resources to create"
  type        = string
}

variable "github_org" {
  description = "The GitHub organization to create teams and repositories in"
  type        = string
}

variable "github_token" {
  description = "The GitHub token to authenticate with the GitHub API"
  type        = string
}

# variable "aws_account_id" {
#   description = "The AWS account ID"
#   type        = string
#   default = "082840391035"
# }

variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default = "eu-central-1"
}