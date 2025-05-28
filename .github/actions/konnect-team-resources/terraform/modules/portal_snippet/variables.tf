variable "content" {
  description = "The renderable markdown content of a snippet in a portal"
  type        = string
}

variable "name" {
  description = "The unique name of a snippet in a portal"
  type        = string
}

variable "portal_id" {
  description = "The Portal identifier"
  type        = string
}

variable "description" {
  description = "Description of the portal snippet"
  type        = string
  default     = null
}

variable "status" {
  description = "Whether the resource is visible on a given portal. Must be one of: published, unpublished"
  type        = string
  default     = "published"

  validation {
    condition     = contains(["published", "unpublished"], var.status)
    error_message = "Status must be either 'published' or 'unpublished'."
  }
}

variable "title" {
  description = "The display title of a snippet in a portal"
  type        = string
  default     = null
}

variable "visibility" {
  description = "Whether a snippet is publicly accessible to non-authenticated users. Default: private"
  type        = string
  default     = "private"
}
