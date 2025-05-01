// variables.tf
variable "environment" {
  description = "The environment resources will be associated with"
  type        = string
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