provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

provider "konnect" {
  personal_access_token = var.konnect_personal_access_token
  server_url            = var.konnect_server_url
}

provider "konnect-beta" {
  personal_access_token = var.konnect_personal_access_token
  server_url            = var.konnect_server_url
}
