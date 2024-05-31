
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

resource "konnect_gateway_control_plane" "tfdemo" {
  name         = "Demo CP"
  description  = "This is a demo Control Plane"
  cluster_type = "CLUSTER_TYPE_HYBRID"
  auth_type    = "pki_client_certs"
  labels = {
    env          = "demo",
    team         = "tfdemo",
    generated_by = "terraform"
  }

  proxy_urls = [
    {
      host     = "example.com",
      port     = 443,
      protocol = "https"
    }
  ]
}

# Add the required data plane certificates 
resource "konnect_gateway_data_plane_client_certificate" "demo_ca_cert" {
  cert             = file("../.tls/ca.crt")
  control_plane_id = konnect_gateway_control_plane.tfdemo.id
}

output "kong_gateway_control_plane_info" {
  value = konnect_gateway_control_plane.tfdemo
}
