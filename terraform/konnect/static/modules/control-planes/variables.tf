// variables.tf
variable "environment" {
  description = "The environment resources will be associated with"
  type        = string
}

variable observability_stack {
  description = "The observability stack to use"
  type        = string
  default     = "grafana"
}

variable vault_address {
  description = "The address of the Vault server"
  type        = string
  default     = "http://localhost:8300"
}

variable "vault_token" {
  description = "value of the vault token"
  type        = string
  default     = "root"
}

variable "host_address" {
  description = "The host address of the docker host. This is used to access the host from the container. It's a local demo specific variable. Not pertinent to real world usage."
  type        = string
  default     = "localhost"
}