variable "name" {
  description = "The name of the portal, used to distinguish it from other portals. Name must be unique."
  type        = string
}

variable "authentication_enabled" {
  description = "Whether the portal supports developer authentication."
  type        = bool
  default     = null
}

variable "auto_approve_applications" {
  description = "Whether requests from applications to register for APIs will be automatically approved."
  type        = bool
  default     = null
}

variable "auto_approve_developers" {
  description = "Whether developer account registrations will be automatically approved."
  type        = bool
  default     = null
}

variable "default_api_visibility" {
  description = "The default visibility of APIs in the portal. Must be one of [\"public\", \"private\"]."
  type        = string
  default     = null
  validation {
    condition     = var.default_api_visibility == null || contains(["public", "private"], var.default_api_visibility)
    error_message = "default_api_visibility must be either \"public\" or \"private\"."
  }
}

variable "default_application_auth_strategy_id" {
  description = "The default authentication strategy for APIs published to the portal."
  type        = string
  default     = null
}

variable "default_page_visibility" {
  description = "The default visibility of pages in the portal. Must be one of [\"public\", \"private\"]."
  type        = string
  default     = null
  validation {
    condition     = var.default_page_visibility == null || contains(["public", "private"], var.default_page_visibility)
    error_message = "default_page_visibility must be either \"public\" or \"private\"."
  }
}

variable "description" {
  description = "A description of the portal."
  type        = string
  default     = null
}

variable "display_name" {
  description = "The display name of the portal."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "If set to \"true\", the portal and all child entities will be deleted when running terraform destroy. Must be one of [\"true\", \"false\"]."
  type        = string
  default     = "false"
  validation {
    condition     = contains(["true", "false"], var.force_destroy)
    error_message = "force_destroy must be either \"true\" or \"false\"."
  }
}

variable "labels" {
  description = "Labels store metadata of an entity that can be used for filtering or searching."
  type        = map(string)
  default     = {}
}

variable "rbac_enabled" {
  description = "Whether the portal resources are protected by Role Based Access Control (RBAC)."
  type        = bool
  default     = null
}