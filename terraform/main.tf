
terraform {
  backend "s3" {}
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

provider "konnect" {
  personal_access_token = var.konnect_personal_access_token
  server_url            = var.konnect_server_url
}

resource "konnect_gateway_control_plane" "tfcpgroup" {
  name         = "Demo CP Group"
  description  = "This is a demo Control Plane Group"
  cluster_type = "CLUSTER_TYPE_CONTROL_PLANE_GROUP"
  auth_type    = "pki_client_certs"

  proxy_urls = []

    labels = {
    env          = "demo",
    team         = "platform",
    generated_by = "terraform"
  }

}

resource "konnect_gateway_control_plane" "tfglobalcp" {
  name         = "Demo Global CP"
  description  = "This is a demo Control Plane"
  cluster_type = "CLUSTER_TYPE_HYBRID"
  auth_type    = "pki_client_certs"
  labels = {
    env          = "demo",
    team         = "platform",
    generated_by = "terraform"
  }

  proxy_urls = []
}

resource "konnect_gateway_control_plane" "tfteamcp" {
  name         = "Demo Team CP"
  description  = "This is a demo Control Plane"
  cluster_type = "CLUSTER_TYPE_HYBRID"
  auth_type    = "pki_client_certs"
  labels = {
    env          = "demo",
    team         = "team1",
    generated_by = "terraform"
  }

  proxy_urls = []
}

resource "konnect_gateway_control_plane_membership" "gatewaycontrolplanemembership" {
  id = konnect_gateway_control_plane.tfcpgroup.id
  members = [
    { id = konnect_gateway_control_plane.tfglobalcp.id },
    { id = konnect_gateway_control_plane.tfteamcp.id }
  ]
}

# Add the required data plane certificates to the control plane group
resource "konnect_gateway_data_plane_client_certificate" "demo_ca_cert" {
  cert             = file("../.tls/ca.crt")
  control_plane_id = konnect_gateway_control_plane.tfcpgroup.id
}

output "kong_gateway_control_plane_info" {
  value = konnect_gateway_control_plane.tfcpgroup
}
