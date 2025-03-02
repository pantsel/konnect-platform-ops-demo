provider "konnect" {
  personal_access_token = var.konnect_personal_access_token
  server_url            = var.konnect_server_url
}

provider "github" {
  token = var.github_token
  owner = var.github_org
}

provider "aws" {
  region = var.aws_region
}
