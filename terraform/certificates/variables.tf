// variables.tf
variable "vault_address" {
  description = "The address of the Vault server"
  type        = string
  default = "http://localhost:8300"
}

variable "vault_token" {
  description = "The token to authenticate with Vault"
  type        = string
  default = "root"
}