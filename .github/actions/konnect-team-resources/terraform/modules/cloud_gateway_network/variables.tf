variable "name" {
  description = "The name of the network"
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block of the network"
  type        = string
}

variable "region" {
  description = "The region of the network"
  type        = string
}

variable "availability_zones" {
  description = "The availability zones of the network"
  type        = list(string)
}

variable "labels" {
  description = "Labels to apply to the network"
  type        = map(string)
  default     = {}
}