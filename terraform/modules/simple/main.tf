
terraform {
  required_providers {
    konnect = {
      source                = "kong/konnect"
      configuration_aliases = [konnect.global]
    }
  }
}

locals {
  cert_path       = "../../../environments/${var.environment}/simple/.tls/ca.crt"
  days_to_hours   = 365 * 24 // 1 year
  expiration_date = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
}

# Provision control Plane
resource "konnect_gateway_control_plane" "cp" {
  name         = "demo_cp"
  description  = "This is a demo Control plane"
  cluster_type = "CLUSTER_TYPE_HYBRID"
  auth_type    = "pki_client_certs"

  labels = {
    generated_by = "terraform"
    environment  = var.environment
  }
}

# Add the required data plane certificate to the control plane
resource "konnect_gateway_data_plane_client_certificate" "cacertcp" {
  cert             = file(local.cert_path)
  control_plane_id = konnect_gateway_control_plane.cp.id
}

# Create system account
resource "konnect_system_account" "sa" {
  name            = "${var.environment}_system_account"
  description     = "This is a demo system account"
  konnect_managed = false

  provider = konnect.global
}

# Create an access token for the system account
resource "konnect_system_account_access_token" "satoken" {

  name       = "${var.environment}_system_account_token"
  expires_at = local.expiration_date
  account_id = konnect_system_account.sa.id

  provider = konnect.global

}

# System Account Role Assignments (CP Admin)
resource "konnect_system_account_role" "sarole" {

  entity_id = konnect_gateway_control_plane.cp.id

  entity_region    = "eu"
  entity_type_name = "Control Planes"
  role_name        = "Admin"
  account_id       = konnect_system_account.sa.id


  provider = konnect.global

}

# Provision a portal
resource "konnect_portal" "demoportal" {
  name                      = "My Demo Portal"
  description               = "This is a demo portal"
  auto_approve_applications = false
  auto_approve_developers   = false
  # custom_domain             = "demo.example.com"
  is_public    = false
  rbac_enabled = false
  labels = {
    generated_by = "terraform"
    environment  = var.environment
  }
}


output "system_account_access_tokens" {
  value     = [
    konnect_system_account_access_token.satoken
  ]
  sensitive = true
}
