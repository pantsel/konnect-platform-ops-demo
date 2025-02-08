variable "name" {
  description = "API Product name"
  type        = string
}

variable "description" {
  description = "API Product description"
  type        = string
}

variable "labels" {
  description = "Labels to apply to the API Product"
  type        = map(string)
  default     = {}
}

variable "public_labels" {
  description = "Public labels to apply to the API Product"
  type        = map(string)
  default     = {}
}
