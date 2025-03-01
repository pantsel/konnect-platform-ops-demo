// variables.tf

variable "konnect_personal_access_token" {
  description = "The Konnect Personal Access Token to use for API requests"
  type        = string
}

variable "konnect_server_url" {
  description = "The URL of the Konnect server to connect to"
  type        = string
}

variable "konnect_region" {
  description = "The region to create the resources in"
  default     = "eu"
  type        = string
}

variable "config" {
  description = "Configuration for the resources to create"
  type        = string
}

variable "vault_address" {
  description = "The address of the Vault server"
  type        = string
}

variable "vault_token" {
  description = "The token to authenticate with the Vault server"
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

variable "minio_server" {
  description = "The Minio server to connect to"
  type        = string
  default = "localhost:9000"
}

variable "minio_ssl" {
  description = "Whether to use SSL when connecting to Minio"
  type = bool
  default = true
  
}

variable "minio_user" {
  description = "The Minio user to authenticate with"
  type = string
  default = "minio-root-user"
}

variable "minio_password" {
  description = "The Minio password to authenticate with"
  type = string
  default = "minio-root-password"
}