// variables.tf
variable "environment" {
  description = "The environment resources will be associated with"
  type        = string
}

variable metadata {
  description = "The metadata for the resources"
  type        = map
}

variable control_planes {
  description = "The control planes to create"
  type = list(any)
}