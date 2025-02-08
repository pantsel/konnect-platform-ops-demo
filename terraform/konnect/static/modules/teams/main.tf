terraform {
    required_providers {
    konnect = {
      source  = "kong/konnect"
    }
  }
}

# Demo Team
resource "konnect_team" "demo_cp_team_readonly" {
  name        = "Demo CP Team Readonly"
  description = "Allow read-only access to the demo control plane"

  labels = {
    generated_by = "terraform"
    environment  = var.environment
  }
}

# Make the team an admin of the demo control plane
resource "konnect_team_role" "demo_cp_viewer_role" {
  entity_id        = var.control_planes.demo_cp.id
  entity_region    = var.konnect_region
  entity_type_name = "Control Planes"
  role_name        = "Viewer"
  team_id          = konnect_team.demo_cp_team_readonly.id
}
