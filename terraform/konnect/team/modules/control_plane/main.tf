terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

resource "konnect_gateway_control_plane" "this" {
  name         = var.name
  description  = var.description
  cluster_type = var.cluster_type
  auth_type    = var.auth_type
  labels = merge(var.labels, {
    generated_by = "terraform"
  })
}

resource "konnect_gateway_data_plane_client_certificate" "this" {
  cert             = var.cacert
  control_plane_id = konnect_gateway_control_plane.this.id
}

output "control_plane" {
  value = konnect_gateway_control_plane.this
}
