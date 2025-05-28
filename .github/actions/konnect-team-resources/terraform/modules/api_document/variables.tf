variable "api_id" {
  description = "The UUID API identifier"
  type        = string
}

variable "content" {
  description = "Raw markdown content to display in your Portal"
  type        = string
}

variable "labels" {
  description = "Labels store metadata of an entity that can be used for filtering an entity list or for searching across entity types. Keys must be of length 1-63 characters, and cannot start with 'kong', 'konnect', 'mesh', 'kic', or '_'"
  type        = map(string)
  default     = {}
}

variable "parent_document_id" {
  description = "API Documents may be rendered as a tree of files. Specify the id of another API Document as the parent_document_id to add some hierarchy to your documents"
  type        = string
  default     = null
}

variable "slug" {
  description = "The slug is used in generated URLs to provide human readable paths. Defaults to slugify(title)"
  type        = string
  default     = null
}

variable "status" {
  description = "If status=published the document will be visible in your live portal. Must be one of ['published', 'unpublished']"
  type        = string
  default     = "unpublished"
  validation {
    condition     = contains(["published", "unpublished"], var.status)
    error_message = "status must be either 'published' or 'unpublished'."
  }
}

variable "title" {
  description = "The title of the document. Used to populate the <title> tag for the page"
  type        = string
  default     = null
}
