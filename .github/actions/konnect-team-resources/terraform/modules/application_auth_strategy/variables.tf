variable "key_auth" {
  description = "Response payload from creating or updating a Key Auth Application Auth Strategy."
  type = object({
    configs = optional(object({
      key_auth = optional(object({
        key_names = optional(list(string))
      }))
    }))
    display_name  = optional(string)
    labels        = optional(map(string))
    name          = optional(string)
    strategy_type = optional(string)
  })
  default = null
}

variable "openid_connect" {
  description = "Response payload from creating an OIDC Application Auth Strategy."
  type = object({
    configs = optional(object({
      openid_connect = optional(object({
        additional_properties = optional(string)
        auth_methods          = optional(list(string))
        credential_claim      = optional(list(string))
        issuer                = optional(string)
        labels                = optional(map(string))
        scopes                = optional(list(string))
      }))
    }))
    dcr_provider_id = optional(string)
    display_name    = optional(string)
    labels          = optional(map(string))
    name            = optional(string)
    strategy_type   = optional(string)
  })
  default = null
}
