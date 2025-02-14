terraform {
    required_providers {
    konnect = {
      source  = "kong/konnect"
    }
  }
}

# Internal Portal
resource "konnect_portal" "internal_portal" {
  name                      = "Internal Portal - ${var.environment}"
  description               = "Internal Portal for the ${var.environment} environment"
  auto_approve_applications = true
  auto_approve_developers   = true
  # custom_domain             = "demo.example.com"
  is_public    = false
  rbac_enabled = false
  labels = {
    generated_by = "terraform"
    environment  = var.environment
  }
}

# External Portal
resource "konnect_portal" "external_portal" {
  name                      = "External Portal - ${var.environment}"
  description               = "External Portal for the ${var.environment} environment"
  auto_approve_applications = false
  auto_approve_developers   = false
  # custom_domain             = "demo.example.com"
  is_public    = true
  rbac_enabled = false
  labels = {
    generated_by = "terraform"
    environment  = var.environment
  }
}