terraform {
  required_providers {
    konnect-beta = {
      source = "kong/konnect-beta"
    }
  }
}

resource "konnect_api_implementation" "this" {
  provider = konnect-beta

  api_id = var.api_id

  service = {
    control_plane_id = var.service.control_plane_id
    id               = var.service.id
  }
}
