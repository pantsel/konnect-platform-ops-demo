// variables.tf
variable "environment" {
  description = "The environment resources will be associated with"
  type        = string
}

variable "teams" {
  description = "The teams to associate with the system accounts"
  type        = any
}