terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

resource "konnect_gateway_control_plane_membership" "this" {
  id      = var.id
  members = var.members
}

output "control_plane_membership" {
  value = konnect_gateway_control_plane_membership.this
}
