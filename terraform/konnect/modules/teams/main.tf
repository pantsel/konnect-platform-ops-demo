terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

# Provision the team
resource "konnect_team" "team" {
  name        = title(var.metadata.name)
  description = lookup(var.metadata, "description", "")

  labels = {
    generated_by = "terraform"
  }
}

# Give the team viewer access to the control planes
resource "konnect_team_role" "teamroles" {
  for_each = { for cp in var.control_planes : cp.name => cp }

  entity_id        = each.value.id
  entity_region    = lookup(var.metadata, "region", "")
  entity_type_name = "Control Planes"
  role_name        = "Viewer"
  team_id          = konnect_team.team.id

}

# Give the team viewer access to the API Products
resource "konnect_team_role" "teamroles_products" {
  for_each = { for product in var.api_products : product.name => product }

  entity_id        = each.value.id
  entity_region    = lookup(var.metadata, "region", "")
  entity_type_name = "API Products"
  role_name        = "Viewer"
  team_id          = konnect_team.team.id

}