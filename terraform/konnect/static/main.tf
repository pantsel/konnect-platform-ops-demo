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
  observability_stack = var.observability_stack
  vault_address = var.vault_address
  vault_token   = var.vault_token
  host_address  = var.host_address
}

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
  konnect_portal_oidc_client_id = var.konnect_portal_oidc_client_id
  konnect_portal_oidc_client_secret = var.konnect_portal_oidc_client_secret
  konnect_portal_oidc_issuer = var.konnect_portal_oidc_issuer
}
