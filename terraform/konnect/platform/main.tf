terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

module "developer_portals" {
  source      = "./modules/developer-portals"
  environment = var.environment
}
