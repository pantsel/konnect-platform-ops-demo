terraform {
  required_providers {
    konnect-beta = {
      source = "kong/konnect-beta"
    }
  }
}

resource "konnect_api_document" "this" {
  provider = konnect-beta

  # Required fields
  api_id  = var.api_id
  content = var.content

  # Optional fields
  labels             = var.labels
  parent_document_id = var.parent_document_id
  slug               = var.slug
  status             = var.status
  title              = var.title
}
