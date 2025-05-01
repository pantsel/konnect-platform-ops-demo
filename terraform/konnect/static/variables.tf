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

variable "host_address" {
  description = "The host address of the docker host. This is used to access the host from the container. It's a local demo specific variable. Not pertinent to real world usage."
  type        = string
  default     = "localhost"
}

variable "konnect_portal_oidc_client_id" {
  description = "The OIDC client ID for the Konnect portal"
  type        = string
}

variable "konnect_portal_oidc_client_secret" {
  description = "The OIDC client secret for the Konnect portal"
  type        = string
}

variable "konnect_portal_oidc_issuer" {
  description = "The OIDC issuer for the Konnect portal"
  type        = string
}