terraform {
  required_providers {
    konnect-beta = {
      source = "kong/konnect-beta"
    }
  }
}

resource "konnect_portal_team" "this" {
  provider = konnect-beta

  name        = var.name
  portal_id   = var.portal_id
  description = var.description
}
