terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

resource "konnect_api_product" "api_products" {

  for_each = { for api_product in var.api_products : api_product.name => api_product }

  description = each.value.description
  labels = merge(lookup(each.value, "labels", {}), {
    generated_by = "terraform"
  })
  name = each.value.name
  portal_ids = [
  ]
  public_labels = lookup(each.value, "public_labels", {})
}

output "api_products" {
  value = [for product in konnect_api_product.api_products : product]
}