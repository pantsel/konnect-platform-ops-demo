provider "konnect" {
  personal_access_token = var.konnect_personal_access_token
  server_url            = var.konnect_server_url
}

provider "konnect-beta" {
  personal_access_token = var.konnect_personal_access_token
  server_url            = var.konnect_server_url
}
