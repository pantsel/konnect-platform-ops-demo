terraform {
  required_providers {
    konnect-beta = {
      source = "kong/konnect-beta"
    }
  }
}

resource "konnect_portal_snippet" "this" {
  provider = konnect-beta

  # Required fields
  content   = var.content
  name      = var.name
  portal_id = var.portal_id

  # Optional fields
  description = var.description
  status      = var.status
  title       = var.title
  visibility  = var.visibility
}
