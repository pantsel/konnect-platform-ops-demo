provider "konnect" {
  personal_access_token = var.konnect_personal_access_token
  server_url            = var.konnect_server_url
}

provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

provider "github" {
  token = var.github_token
  owner = var.github_org
}
provider "minio" {
  minio_server   = var.minio_server
  minio_user     = var.minio_user
  minio_password = var.minio_password
}
