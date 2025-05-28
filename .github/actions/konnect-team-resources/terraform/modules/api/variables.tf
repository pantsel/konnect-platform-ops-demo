variable "name" {
  description = "The name of your API. The name + version combination must be unique for each API you publish"
  type        = string
}

variable "deprecated" {
  description = "Marks this API as deprecated"
  type        = bool
  default     = false
}

variable "description" {
  description = "A description of your API. Will be visible on your live Portal"
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels store metadata of an entity that can be used for filtering an entity list or for searching across entity types. Keys must be of length 1-63 characters, and cannot start with 'kong', 'konnect', 'mesh', 'kic', or '_'"
  type        = map(string)
  default     = {}
}

variable "slug" {
  description = "The slug is used in generated URLs to provide human readable paths. Defaults to slugify(name + version)"
  type        = string
  default     = null
}

variable "spec_content" {
  description = "The content of the API specification. This is the raw content of the API specification, in json or yaml. By including this field, you can add a API specification without having to make a separate call to update the API specification. Requires replacement if changed"
  type        = string
  default     = null
}

variable "api_version" {
  description = "An optional version for your API. Leave this empty if your API is unversioned"
  type        = string
  default     = null
}
