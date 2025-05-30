variable "name" {
  description = "The name of the portal team"
  type        = string
}

variable "portal_id" {
  description = "The Portal identifier"
  type        = string
}

variable "description" {
  description = "The description of the portal team"
  type        = string
  default     = null
}
