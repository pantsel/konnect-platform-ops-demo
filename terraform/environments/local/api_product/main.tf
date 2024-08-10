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

module "api_product" {
  source  = "../../../modules/api_product"

  api_name = var.api_name
  api_description = var.api_description
  api_version = var.api_version
  konnect_control_plane_id = var.konnect_control_plane_id
  konnect_gateway_service_id = var.konnect_gateway_service_id
}

data "konnect_portal_list" "portallist" {
  page_number = 1
  page_size   = 1
}
