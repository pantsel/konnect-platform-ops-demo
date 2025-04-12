terraform {
    required_providers {
    konnect = {
      source  = "kong/konnect"
    }
  }
}

# Demo portal
resource "konnect_portal" "demo_portal" {
  name                      = "Demo Portal"
  description               = "Demo Portal"
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