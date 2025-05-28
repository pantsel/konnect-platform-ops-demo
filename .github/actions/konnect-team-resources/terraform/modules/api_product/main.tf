terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

resource "konnect_api_product" "this" {

  name        = var.name
  description = var.description
  labels = merge(var.labels, {
    generated_by = "terraform"
  })
  public_labels = var.public_labels

  # Keep portal_ids empty for now. 
  # We are only provisioning the API Product in this stage of operations.
  portal_ids = []
}

output "api_product" {
  value = konnect_api_product.this
}
