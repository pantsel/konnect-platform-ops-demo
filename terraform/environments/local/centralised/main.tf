terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

provider "konnect" {
  personal_access_token = var.konnect_personal_access_token
  server_url            = var.konnect_server_url
}

provider "konnect" {
  alias                 = "global"
  personal_access_token = var.konnect_personal_access_token
  server_url            = "https://global.api.konghq.com"
}

module "centralised" {
  source  = "../../../modules/centralised"
  providers = {
    konnect.global = konnect.global
  }
}

# output "system_account_access_tokens" {
#   value = module.centralised.system_account_access_tokens
#   sensitive = true
# }

# output "kong_gateway_control_plane_info" {
#   value = module.centralised.kong_gateway_control_plane_info
# }

output "konnect_team_tfteams" {
  value = module.centralised.konnect_team_tfteams
}

output "konnect_gateway_control_plane_tfcps" {
  value = module.centralised.konnect_gateway_control_plane_tfcps
}

output "team_roles" {
  value = module.centralised.team_roles
}
