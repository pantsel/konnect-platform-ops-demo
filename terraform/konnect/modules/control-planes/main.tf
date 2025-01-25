terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

locals {
  cert_path = ".tls/ca.crt"
}

# Create a Konnect Gateway Control Plane for each control plane in the resources
resource "konnect_gateway_control_plane" "cps" {
  for_each = { for cp in var.control_planes : cp.name => cp }

  name         = each.value.name
  description  = each.value.description
  cluster_type = lookup(each.value, "cluster_type", "CLUSTER_TYPE_HYBRID")
  auth_type    = lookup(each.value, "auth_type", "pki_client_certs")
  labels = merge(lookup(each.value, "labels", {}), {
    generated_by = "terraform",
    env          = var.environment
  })
}

# Add the required data plane certificates to the control planes
resource "konnect_gateway_data_plane_client_certificate" "cacertcp" {
  for_each = { for cp in konnect_gateway_control_plane.cps : cp.name => cp }

  cert             = file(local.cert_path)
  control_plane_id = each.value.id
}

output "control_planes" {
  value = [for cp in konnect_gateway_control_plane.cps : cp]
}