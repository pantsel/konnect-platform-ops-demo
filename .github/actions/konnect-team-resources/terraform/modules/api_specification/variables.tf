variable "api_id" {
  description = "The UUID API identifier"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.api_id))
    error_message = "The api_id must be a valid UUID."
  }
}

variable "content" {
  description = "The raw content of your API specification, in json or yaml format (OpenAPI or AsyncAPI)"
  type        = string

  validation {
    condition     = length(var.content) > 0
    error_message = "The content must not be empty."
  }
}

variable "type" {
  description = "The type of specification being stored. If not set, it will be autodetected from content."
  type        = string
  default     = null

  validation {
    condition     = var.type == null || contains(["oas2", "oas3", "asyncapi"], var.type)
    error_message = "The type must be one of: oas2, oas3, asyncapi."
  }
}
