// variables.tf

variable "environment" {
  description = "The environment resources will be associated with"
  type        = string
}

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

variable "vault_address" {
  description = "The address of the Vault server"
  type        = string
  default = "http://localhost:8300"
}

variable "vault_token" {
  description = "The token to authenticate with Vault"
  type        = string
  default = "root"
}

variable "observability_stack" {
  description = "The observability stack to use"
  type        = string
  default     = "grafana"
}