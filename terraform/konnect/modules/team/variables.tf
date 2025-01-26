variable "name" {
  description = "Prefix for the system account name"
  type        = string
}

variable "description" {
  description = "Description of the system account"
  type        = string
}

variable "region" {
  description = "Region where the system account is created"
  type        = string
  default     = ""
}

variable "control_planes" {
  description = "List of control planes"
  type        = list(any)
}

variable "api_products" {
  description = "List of API products"
  type        = list(any)
}
