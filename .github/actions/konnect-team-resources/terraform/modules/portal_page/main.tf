terraform {
  required_providers {
    konnect-beta = {
      source = "kong/konnect-beta"
    }
  }
}

resource "konnect_portal_page" "this" {
  provider = konnect-beta

  # Required fields
  content   = var.content
  portal_id = var.portal_id
  slug      = var.slug

  # Optional fields
  description    = var.description
  parent_page_id = var.parent_page_id
  status         = var.status
  title          = var.title
  visibility     = var.visibility
}
