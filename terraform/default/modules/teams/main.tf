terraform {
    required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "1.0.0"
    }
  }
}

# Demo Team
resource "konnect_team" "demo_team" {
  name        = "Demo Team"
  description = "This is a team that is managed by Terraform"

  labels = {
    generated_by = "terraform"
    environment  = var.environment
  }
}

# Make the team an admin of the demo control plane
resource "konnect_team_role" "demo_cp_admin_role" {
  entity_id        = var.control_planes.demo_cp.id
  entity_region    = "eu"
  entity_type_name = "Control Planes"
  role_name        = "Admin"
  team_id          = konnect_team.demo_team.id
}
