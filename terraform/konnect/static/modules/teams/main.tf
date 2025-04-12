terraform {
    required_providers {
    konnect = {
      source  = "kong/konnect"
    }
  }
}

# Flight Data Team
resource "konnect_team" "flight_data_team" {
  name        = "Flight Data Team"
  description = "Flight Data Team"

  labels = {
    generated_by = "terraform"
    environment  = var.environment
    team         = "flight-data"
  }
}

# Make the team a Viewer of the flight data control plane
resource "konnect_team_role" "flight_data_cp_role" {
  entity_id        = var.control_planes.flight_data_cp.id
  entity_region    = var.konnect_region
  entity_type_name = "Control Planes"
  role_name        = "Viewer"
  team_id          = konnect_team.flight_data_team.id
}