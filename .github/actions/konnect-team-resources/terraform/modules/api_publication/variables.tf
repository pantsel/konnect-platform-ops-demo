variable "api_id" {
  description = "The UUID API identifier."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.api_id))
    error_message = "The api_id must be a valid UUID."
  }
}

variable "portal_id" {
  description = "The Portal identifier."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.portal_id))
    error_message = "The portal_id must be a valid UUID."
  }
}

variable "auth_strategy_ids" {
  description = "The auth strategy the API enforces for applications in the portal. Omitting this property means the portal's default application auth strategy will be used. Setting to null means the API will not require application authentication."
  type        = list(string)
  default     = null

  validation {
    condition = var.auth_strategy_ids == null ? true : alltrue([
      for id in var.auth_strategy_ids : can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", id))
    ])
    error_message = "All auth_strategy_ids must be valid UUIDs."
  }
}

variable "auto_approve_registrations" {
  description = "Whether the application registration auto approval on this portal for the api is enabled. If set to false, fallbacks on portal's auto_approve_applications value."
  type        = bool
  default     = null
}

variable "visibility" {
  description = "The visibility of the API in the portal. Public API publications do not require authentication to view and retrieve information about them. Private API publications require authentication to retrieve information about them."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private"], var.visibility)
    error_message = "The visibility must be either 'public' or 'private'."
  }
}
