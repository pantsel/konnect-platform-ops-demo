terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}


resource "konnect_team_role" "this" {

  for_each = merge(
    { for cp in var.control_planes : cp.name => { name = cp.name, id = cp.id, type = "Control Planes" } },
    //{ for product in var.api_products : product.name => { name = product.name, id = product.id, type = "API Products" } }
  )

  entity_id        = each.value.id
  entity_region    = var.region
  entity_type_name = each.value.type
  role_name        = "Viewer"
  team_id          = var.team.id

}

