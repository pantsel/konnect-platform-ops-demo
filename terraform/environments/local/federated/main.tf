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

module "federated" {
  source  = "../../../modules/federated"
  providers = {
    konnect.global = konnect.global
  }
}

output "system_account_access_token" {
  value = module.federated.system_account_access_token
  sensitive = true
}

output "kong_gateway_control_plane_info" {
  value = module.federated.kong_gateway_control_plane_info
}

