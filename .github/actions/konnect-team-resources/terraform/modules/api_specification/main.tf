terraform {
  required_providers {
    konnect-beta = {
      source = "kong/konnect-beta"
    }
  }
}

resource "konnect_api_specification" "this" {
    provider = konnect-beta
  api_id  = var.api_id
  content = var.content
  type    = var.type
}
