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
  description = "A list of control planes the team will have access to"
  type = list(any)
}

variable api_products {
  description = "A list of api products the team will have access to"
  type        = list(any)
}