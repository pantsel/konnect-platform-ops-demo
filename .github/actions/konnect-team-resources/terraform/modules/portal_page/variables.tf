variable "content" {
  description = "The renderable markdown content of a page in a portal"
  type        = string
}

variable "portal_id" {
  description = "The Portal identifier"
  type        = string
}

variable "slug" {
  description = "The slug of a page in a portal. Is used to compute the full path /slug1/slug2/slug3"
  type        = string
}

variable "description" {
  description = "Description of the portal page"
  type        = string
  default     = null
}

variable "parent_page_id" {
  description = "Pages may be rendered as a tree of files. Specify the id of another page as the parent_page_id to add some hierarchy to your pages"
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
  description = "The title of a page in a portal"
  type        = string
  default     = null
}

variable "visibility" {
  description = "Whether a page is publicly accessible to non-authenticated users. Default: private"
  type        = string
  default     = "private"
}
