// variables.tf
variable "environment" {
  description = "The environment to run"
  type        = string
  default     = "local"
}