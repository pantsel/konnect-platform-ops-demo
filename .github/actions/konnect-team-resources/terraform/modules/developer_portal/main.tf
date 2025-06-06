terraform {
  required_providers {
    konnect-beta = {
      source = "kong/konnect-beta"
    }
    konnect = {
      source = "kong/konnect"
    }
  }
}

resource "konnect_portal" "this" {
  provider                             = konnect-beta
  name                                 = var.name
  authentication_enabled               = var.authentication_enabled
  auto_approve_applications            = var.auto_approve_applications
  auto_approve_developers              = var.auto_approve_developers
  default_api_visibility               = var.default_api_visibility
  default_application_auth_strategy_id = var.default_application_auth_strategy_id
  default_page_visibility              = var.default_page_visibility
  description                          = var.description
  display_name                         = var.display_name
  force_destroy                        = var.force_destroy
  labels                               = var.labels
  rbac_enabled                         = var.rbac_enabled
}
