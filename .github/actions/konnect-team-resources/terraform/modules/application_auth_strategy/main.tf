terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "2.7.4"
    }
  }
}

resource "konnect_application_auth_strategy" "this" {
  key_auth       = var.key_auth
  openid_connect = var.openid_connect
}
