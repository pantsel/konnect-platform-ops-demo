terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
      version = "2.7.4"
    }
  }
}

locals {
  AWS   = 0
  AZURE = 1
  GCP   = 2
}

data "konnect_cloud_gateway_provider_account_list" "this" {
  page_number = 1
  page_size   = 3
}

// This module creates a Konnect Cloud Gateway Network in Azure (Azure is index 1 in the provider account list)
resource "konnect_cloud_gateway_network" "this" {
  name               = var.name
  cidr_block         = var.cidr_block
  region             = var.region
  availability_zones = var.availability_zones
  cloud_gateway_provider_account_id = data.konnect_cloud_gateway_provider_account_list.this.data[local.AZURE].id
}
output "cloud_gateway_network" {
  value = konnect_cloud_gateway_network.this
}