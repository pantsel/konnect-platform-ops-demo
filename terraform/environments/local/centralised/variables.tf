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

variable "environment" {
  description = "The environment to run"
  type        = string
  default     = "local"
}

variable "resources_file" {
  description = "The path to the resources file"
  type        = string
}