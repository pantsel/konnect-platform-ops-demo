// variables.tf

variable "konnect_personal_access_token" {
  description = "The Konnect Personal Access Token to use for API requests"
  type        = string
  default = "value"
}

variable "konnect_server_url" {
  description = "The URL of the Konnect server to connect to"
  type        = string
  default = "value"
}

variable "konnect_region" {
  description = "The region to create the resources in"
  default     = "us"
  type        = string
}

variable "environment" {
  description = "The environment to run"
  type        = string
  default     = "cloud-gateways"
}
