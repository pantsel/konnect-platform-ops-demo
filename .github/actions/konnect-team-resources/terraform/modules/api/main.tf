terraform {
  required_providers {
    konnect-beta = {
      source = "kong/konnect-beta"
    }
  }
}

resource "konnect_api" "this" {
  provider = konnect-beta

  # Required fields
  name = var.name

  # Optional fields
  deprecated   = var.deprecated
  description  = var.description
  labels       = var.labels
  slug         = var.slug
  spec_content = var.spec_content
  version      = var.api_version
}
