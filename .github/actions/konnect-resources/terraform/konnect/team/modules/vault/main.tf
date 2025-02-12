terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

resource "konnect_gateway_config_store" "this" {
  name  = "${var.control_plane_name}-configstore"

  control_plane_id = var.control_plane_id
}

resource "konnect_gateway_vault" "this" {
  name   = "konnect"
  prefix = "konnect-vault"
  config = jsonencode({
    config_store_id = konnect_gateway_config_store.this.id
  })
  control_plane_id = var.control_plane_id
}
