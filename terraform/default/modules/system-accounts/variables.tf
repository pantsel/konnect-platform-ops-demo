// variables.tf
variable "environment" {
  description = "The environment resources will be associated with"
  type        = string
}

variable "teams" {
  description = "The teams to associate with the system accounts"
  type        = any
}

variable "control_planes" {
  description = "The control planes to associate with the system accounts"
  type        = any
}

variable "konnect_region" {
  description = "The region to create the resources in"
  default     = "eu"
  type        = string
}