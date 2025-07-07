variable "team_name" {
  description = "The name of the team"
  type        = string
}

variable "team_id" {
  description = "The ID of the team"
  type        = string
}

variable "konnect_region" {
  description = "The Konnect region (e.g., 'eu', 'us')"
  type        = string
  default     = "eu"
}