terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
    konnect-beta = {
      source = "kong/konnect-beta"
    }
  }
}

resource "konnect_portal_auth" "this" {
  basic_auth_enabled      = var.basic_auth_enabled
  idp_mapping_enabled     = var.idp_mapping_enabled
  konnect_mapping_enabled = var.konnect_mapping_enabled
  oidc_auth_enabled       = var.oidc_auth_enabled
  oidc_claim_mappings = {
    email  = var.oidc_claim_mappings.email
    groups = var.oidc_claim_mappings.groups
    name   = var.oidc_claim_mappings.name
  }
  oidc_client_id            = var.oidc_client_id
  oidc_client_secret        = var.oidc_client_secret
  oidc_issuer               = var.oidc_issuer
  oidc_scopes               = var.oidc_scopes
  oidc_team_mapping_enabled = var.oidc_team_mapping_enabled
  portal_id                 = var.portal_id
  saml_auth_enabled         = var.saml_auth_enabled
}
