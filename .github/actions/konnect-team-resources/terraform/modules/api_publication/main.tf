terraform {
  required_providers {
    konnect-beta = {
      source = "kong/konnect-beta"
    }
  }
}

resource "konnect_api_publication" "this" {
  provider = konnect-beta

  api_id    = var.api_id
  portal_id = var.portal_id

  auth_strategy_ids          = var.auth_strategy_ids
  auto_approve_registrations = var.auto_approve_registrations
  visibility                 = var.visibility
}
