terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

resource "konnect_system_account" "this" {
  name        = var.name
  description = var.description

  konnect_managed = false
}

resource "konnect_system_account_role" "this" {

  entity_id = var.entity_id

  entity_region    = var.region
  entity_type_name = var.entity_type_name
  role_name        = var.role_name
  account_id       = konnect_system_account.this.id

}

resource "konnect_system_account_access_token" "this" {

  name       = var.name
  expires_at = var.expiration_date
  account_id = konnect_system_account.this.id
}


output "access_token" {
  value = konnect_system_account_access_token.this
}
