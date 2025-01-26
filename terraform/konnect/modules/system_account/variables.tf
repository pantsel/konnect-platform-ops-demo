variable "name" {
  description = "Prefix for the system account name"
  type        = string
}

variable "description" {
  description = "Description of the system account"
  type        = string
}

variable "entity_id" {
  description = "ID of the entity the system account is associated with"
  type        = string
}

variable "entity_type_name" {
  description = "Type of the entity the system account is associated with"
  type        = string
}

variable "role_name" {
  description = "Role name assigned to the system account"
  type        = string
}

variable "expiration_date" {
  description = "Expiration date of the system account"
  type        = string
}

variable "region" {
  description = "Region where the system account is created"
  type        = string
  default     = ""
}
