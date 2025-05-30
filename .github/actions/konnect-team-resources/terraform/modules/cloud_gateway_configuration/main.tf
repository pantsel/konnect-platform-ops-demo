terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

resource "konnect_cloud_gateway_configuration" "this" {
  api_access        = var.api_access
  control_plane_geo = var.control_plane_geo
  control_plane_id  = var.control_plane_id
  dataplane_groups  = var.dataplane_groups
  version           = var.gateway_version
}
