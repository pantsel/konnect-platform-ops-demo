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

# Control Planes
resource "konnect_gateway_control_plane" "demo_cp" {
  name         = "demo_cp"
  description  = "This is a demo Control plane"
  cluster_type = "CLUSTER_TYPE_HYBRID"
  # Can be "pinned_client_certs" or "pki_client_certs". For "pki_client_certs" we need to provide the CA certificate.
  # https://docs.konghq.com/konnect/gateway-manager/data-plane-nodes/secure-communications/
  auth_type = "pinned_client_certs"

  labels = {
    generated_by = "terraform"
    environment  = var.environment
  }
}

resource "konnect_gateway_control_plane" "global_cp" {
  name         = "global_cp"
  description  = "Control Plane to manage global plugins and policies"
  cluster_type = "CLUSTER_TYPE_HYBRID"
  # Can be "pinned_client_certs" or "pki_client_certs". For "pki_client_certs" we need to provide the CA certificate.
  # https://docs.konghq.com/konnect/gateway-manager/data-plane-nodes/secure-communications/
  auth_type = "pki_client_certs"

  labels = {
    generated_by = "terraform"
    environment  = var.environment
  }
}

resource "konnect_gateway_control_plane" "demo_cp_group" {
  name         = "demo_cp_group"
  description  = "Demo Control Plane Group"
  cluster_type = "CLUSTER_TYPE_CONTROL_PLANE_GROUP"
  # Can be "pinned_client_certs" or "pki_client_certs". For "pki_client_certs" we need to provide the CA certificate.
  # https://docs.konghq.com/konnect/gateway-manager/data-plane-nodes/secure-communications/
  auth_type = "pinned_client_certs"

  labels = {
    generated_by = "terraform"
    environment  = var.environment
  }
}

resource "konnect_gateway_data_plane_client_certificate" "demo_cp_group_dp_cert" {
  cert             = file(local.cert_path)
  control_plane_id = konnect_gateway_control_plane.demo_cp_group.id
}

resource "konnect_gateway_control_plane_membership" "demo_control_plane_group_membership" {
  id = konnect_gateway_control_plane.demo_cp_group.id
  members = [
    {
      id = konnect_gateway_control_plane.demo_cp.id
    },
    {
      id = konnect_gateway_control_plane.global_cp.id
    }
  ]
}

