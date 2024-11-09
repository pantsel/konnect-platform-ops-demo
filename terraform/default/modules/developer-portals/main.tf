terraform {
    required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "1.0.0"
    }
  }
}

# Demo portal
resource "konnect_portal" "demo_portal" {
  name                      = "Demo Portal - ${var.environment}"
  description               = "Demo Portal for the ${var.environment} environment"
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