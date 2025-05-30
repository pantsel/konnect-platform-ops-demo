variable "name" {
  description = "API Product name"
  type        = string
}

variable "description" {
  description = "API Product description"
  type        = string
}

variable "labels" {
  description = "Labels to apply to the API Product"
  type        = map(string)
  default     = {}
}

variable "cluster_type" {
  description = "The type of cluster to create"
  type        = string
  default     = "CLUSTER_TYPE_HYBRID"
}

variable "auth_type" {
  description = "The type of authentication to use"
  type        = string
  default     = "pki_client_certs"
}

variable "cacert" {
  description = "The CA certificate to use for the control plane"
  type        = string
}

variable "cloud_gateway" {
  description = "Indicates if the control plane is a cloud gateway"
  type        = bool
}
