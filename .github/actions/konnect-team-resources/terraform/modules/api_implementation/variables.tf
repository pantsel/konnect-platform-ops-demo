variable "api_id" {
  description = "The UUID API identifier. Requires replacement if changed."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.api_id))
    error_message = "The api_id must be a valid UUID."
  }
}

variable "service" {
  description = "A Gateway service that implements an API. Requires replacement if changed."
  type = object({
    control_plane_id = string
    id               = string
  })

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.service.control_plane_id))
    error_message = "The control_plane_id must be a valid UUID."
  }

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.service.id))
    error_message = "The service id must be a valid UUID."
  }
}
