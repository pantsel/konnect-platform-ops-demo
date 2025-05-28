terraform {
  required_providers {
    konnect-beta = {
      source = "kong/konnect-beta"
    }
  }
}

resource "konnect_portal_custom_domain" "this" {
  provider = konnect-beta

  enabled   = var.enabled
  hostname  = var.hostname
  portal_id = var.portal_id

  ssl = {
    domain_verification_method = var.ssl.domain_verification_method
    custom_certificate         = var.ssl.custom_certificate
    custom_private_key         = var.ssl.custom_private_key
  }
}
