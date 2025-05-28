variable "enabled" {
  description = "Whether the custom domain is enabled"
  type        = bool
}

variable "hostname" {
  description = "The hostname for the custom domain. Requires replacement if changed."
  type        = string
}

variable "portal_id" {
  description = "The Portal identifier"
  type        = string
}

variable "ssl" {
  description = "SSL configuration for the custom domain. Requires replacement if changed."
  type = object({
    domain_verification_method = string
    custom_certificate         = optional(string)
    custom_private_key         = optional(string)
  })

  validation {
    condition     = contains(["http", "custom_certificate"], var.ssl.domain_verification_method)
    error_message = "domain_verification_method must be one of 'http' or 'custom_certificate'."
  }
}
