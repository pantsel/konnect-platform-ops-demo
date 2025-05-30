variable "portal_id" {
  description = "The Portal identifier"
  type        = string
}

variable "basic_auth_enabled" {
  description = "Whether the organization has basic auth enabled."
  type        = bool
  default     = null
}

variable "idp_mapping_enabled" {
  description = "Whether IdP groups determine the Konnect Portal teams a developer has. This will soon replace oidc_team_mapping_enabled."
  type        = bool
  default     = null
}

variable "konnect_mapping_enabled" {
  description = "Whether a Konnect Identity Admin assigns teams to a developer."
  type        = bool
  default     = null
}

variable "oidc_auth_enabled" {
  description = "Whether the organization has OIDC enabled."
  type        = bool
  default     = null
}

variable "oidc_claim_mappings" {
  description = "Mappings from a portal developer attribute to an Identity Provider claim."
  type = object({
    email  = optional(string)
    groups = optional(string)
    name   = optional(string)
  })
  default = null
}

variable "oidc_client_id" {
  description = "OIDC client ID"
  type        = string
  default     = null
}

variable "oidc_client_secret" {
  description = "OIDC client secret"
  type        = string
  default     = null
  sensitive   = true
}

variable "oidc_issuer" {
  description = "OIDC issuer"
  type        = string
  default     = null
}

variable "oidc_scopes" {
  description = "OIDC scopes"
  type        = list(string)
  default     = null
}

variable "oidc_team_mapping_enabled" {
  description = "Whether IdP groups determine the Konnect Portal teams a developer has."
  type        = bool
  default     = null
}

variable "saml_auth_enabled" {
  description = "Whether the portal has SAML enabled or disabled."
  type        = bool
  default     = null
}
