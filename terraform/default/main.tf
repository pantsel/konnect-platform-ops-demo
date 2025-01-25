terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }

  }
}

module "control_planes" {
  source      = "./modules/control-planes"
  environment = var.environment
}

# module "data_plane_certificates" {
#   source         = "./modules/data-plane-certificates"
#   environment    = var.environment
#   control_planes = module.control_planes.control_planes
# }

module "teams" {
  source         = "./modules/teams"
  environment    = var.environment
  control_planes = module.control_planes.control_planes
  konnect_region = var.konnect_region
}

module "system_accounts" {
  source         = "./modules/system-accounts"
  environment    = var.environment
  teams          = module.teams.teams
  control_planes = module.control_planes.control_planes
}

module "developer_portals" {
  source      = "./modules/developer-portals"
  environment = var.environment
}
