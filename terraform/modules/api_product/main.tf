
terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

locals {
}

data "konnect_portal_list" "portallist" {
  page_number = 1
  page_size   = 1
}

locals {
  portal = [
    for portal in data.konnect_portal_list.portallist.data : portal
    if portal.labels["environment"] == var.environment
  ][0]
}

resource "konnect_api_product" "product" {
  name        = "${var.api_name} Product"
  description = var.api_description

  portal_ids = [
    local.portal.id
  ]

  labels = {
    environment  = var.environment
    generated_by = "terraform"
  }
}

resource "konnect_api_product_version" "product_v1" {
  api_product_id = konnect_api_product.product.id
  name           = "v${var.api_version}"
  gateway_service = {
    control_plane_id = var.konnect_control_plane_id
    id               = var.konnect_gateway_service_id
  }
}

resource "konnect_api_product_document" "apiproductdocument" {
  title          = "Documentation"
  content        = base64encode(file("./docs/DOCS.md"))
  slug           = "documentation"
  status         = "published"
  api_product_id = konnect_api_product.product.id
}


resource "konnect_api_product_specification" "product_v1_spec" {
  name                   = "spec.yaml"
  content                = base64encode(file("./openapi_spec.yaml"))
  api_product_id         = konnect_api_product.product.id
  api_product_version_id = konnect_api_product_version.product_v1.id
}

# resource "konnect_application_auth_strategy" "applicationauthstrategy" {
#   key_auth = {
#     name          = "my-application-auth-strategy"
#     key_names     = ["apikey"]
#     display_name  = "API Key Strategy"
#     strategy_type = "key_auth"
#     configs = {
#       key_auth = {
#         key_names = ["apikey"]
#       }
#     }
#   }
# }

resource "konnect_portal_product_version" "portalproductversion" {
  application_registration_enabled = false
  auto_approve_registration        = false
  deprecated                       = false
  publish_status                   = "published"

  portal_id          = local.portal.id
  product_version_id = konnect_api_product_version.product_v1.id
  auth_strategy_ids = [
    #konnect_application_auth_strategy.applicationauthstrategy.id
  ]
}
