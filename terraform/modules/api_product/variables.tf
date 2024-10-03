// variables.tf
variable "environment" {
  description = "The environment to run"
  type        = string
  default     = "local"
}

variable "api_name" {
  description = "The name of the API"
  type        = string
}

variable "api_description" {
  description = "The description of the API"
  type        = string
}

variable "api_version" {
  description = "The version of the API"
  type        = string
}

variable "konnect_control_plane_id" {
  description = "The Konnect Control Plane ID"
  type        = string
}

variable "konnect_gateway_service_id" {
  description = "The Konnect Gateway Service ID to associate the API product version with"
  type        = string
}