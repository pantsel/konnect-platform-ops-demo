// variables.tf

variable "konnect_personal_access_token" {
  description = "The Konnect Personal Access Token to use for API requests"
  type        = string
}

variable "konnect_server_url" {
  description = "The URL of the Konnect server to connect to"
  type        = string
}

variable "konnect_region" {
  description = "The region to create the resources in"
  default     = "eu"
  type        = string
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
