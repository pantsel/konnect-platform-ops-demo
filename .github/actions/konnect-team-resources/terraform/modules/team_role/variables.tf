variable "team" {
  description = "The team to assign the resources to"
  type = object({
    id   = string
    name = string
  })
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
