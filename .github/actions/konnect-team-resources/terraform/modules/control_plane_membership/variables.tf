variable "id" {
  description = "Control Plane Membership ID"
  type        = string
}

variable "members" {
  description = "CP Members"
  type = list(object({
    id = string
  }))
}