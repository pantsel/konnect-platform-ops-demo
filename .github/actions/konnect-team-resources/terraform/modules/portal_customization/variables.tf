variable "portal_id" {
  description = "The Portal identifier"
  type        = string
}

variable "css" {
  description = "Custom CSS styles for the portal"
  type        = string
  default     = null
}

variable "js" {
  description = "JavaScript configuration for the portal"
  type        = any
  default     = null
}

variable "layout" {
  description = "Custom layout template for the portal"
  type        = string
  default     = null
}

variable "menu" {
  description = "Menu configuration for the portal"
  type        = any
  default     = null
}

variable "robots" {
  description = "Robots.txt content for the portal"
  type        = string
  default     = null
}

variable "spec_renderer" {
  description = "Specification renderer configuration"
  type        = any
  default     = null
}

variable "theme" {
  description = "Theme configuration for the portal"
  type        = any
  default     = null
}
