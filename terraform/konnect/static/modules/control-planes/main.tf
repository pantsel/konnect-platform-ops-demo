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
resource "konnect_gateway_control_plane" "flight_data_cp" {
  name         = "flight-data"
  description  = "Control Plane for flight data apis"
  cluster_type = "CLUSTER_TYPE_HYBRID"
  # Can be "pinned_client_certs" or "pki_client_certs". For "pki_client_certs" we need to provide the CA certificate.
  # https://docs.konghq.com/konnect/gateway-manager/data-plane-nodes/secure-communications/
  auth_type = "pinned_client_certs"

  labels = {
    generated_by = "terraform"
    team         = "flight-data"
  }
}

resource "konnect_gateway_control_plane" "platform_cp" {
  name         = "platform-cp"
  description  = "Control Plane to manage global plugins and policies"
  cluster_type = "CLUSTER_TYPE_HYBRID"
  # Can be "pinned_client_certs" or "pki_client_certs". For "pki_client_certs" we need to provide the CA certificate.
  # https://docs.konghq.com/konnect/gateway-manager/data-plane-nodes/secure-communications/
  auth_type = "pki_client_certs"

  labels = {
    generated_by = "terraform"
    team         = "platform"
  }
}

resource "konnect_gateway_control_plane" "flight_data_cp_group" {
  name         = "flight-data-cp-group"
  description  = "Flight Data Control Plane Group"
  cluster_type = "CLUSTER_TYPE_CONTROL_PLANE_GROUP"
  # Can be "pinned_client_certs" or "pki_client_certs". For "pki_client_certs" we need to provide the CA certificate.
  # https://docs.konghq.com/konnect/gateway-manager/data-plane-nodes/secure-communications/
  auth_type = "pki_client_certs"

  labels = {
    generated_by = "terraform"
  }
}

resource "konnect_gateway_data_plane_client_certificate" "flight_data_cp_group_dp_cert" {
  cert             = file(local.cert_path)
  control_plane_id = konnect_gateway_control_plane.flight_data_cp_group.id
}

resource "konnect_gateway_control_plane_membership" "flight_data_control_plane_group_membership" {
  id = konnect_gateway_control_plane.flight_data_cp_group.id
  members = [
    {
      id = konnect_gateway_control_plane.flight_data_cp.id
    },
    {
      id = konnect_gateway_control_plane.platform_cp.id
    }
  ]
}

