// variables.tf
variable "environment" {
  description = "The environment to run"
  type        = string
  default     = "local"
}

variable "resources_file" {
  description = "The path to the resources file"
  type        = string
}