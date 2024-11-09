terraform {
    required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "1.0.0"
    }
  }
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
