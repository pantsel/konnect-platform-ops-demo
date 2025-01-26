// variables.tf
variable "environment" {
  description = "The environment resources will be associated with"
  type        = string
}

variable metadata {
  description = "The metadata for the resources"
  type        = map
}

variable api_products {
  description = "The API products to create"
  type        = list(any)
}