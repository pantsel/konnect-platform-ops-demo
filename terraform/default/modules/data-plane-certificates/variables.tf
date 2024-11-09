// variables.tf
variable "environment" {
  description = "The environment resources will be associated with"
  type        = string
}

variable "control_planes" {
  description = "The control planes to add the certificates to"
  type        = any
}