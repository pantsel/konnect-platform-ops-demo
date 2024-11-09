// This module generates a certificate for each control plane defined in the control-planes module.
// Each certificate is stored in Vault and provisioned on the respective control plane in Konnect.

terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "1.0.0"
    }
  }
}

# Create a data plane client certificates for each control plane
# using the private key from the vault.
resource "tls_self_signed_cert" "cp_cert" {
  for_each = var.control_planes

  private_key_pem = data.vault_kv_secret_v2.tls.data.tls_key

  subject {
    common_name  = "konnect-${each.key}"
    organization = local.cert.subject.organization
    country      = local.cert.subject.country
  }

  validity_period_hours = 8760
  is_ca_certificate     = true
  allowed_uses          = local.cert.allowed_uses
}

# Store the certificates in Vault
resource "vault_kv_secret_v2" "cp_cert_kv_secret" {
  for_each            = tls_self_signed_cert.cp_cert
  mount               = local.kv_mount
  name                = "tls/${each.key}"
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode(
    {
      tls_crt = each.value.cert_pem,
    }
  )

  custom_metadata {
    max_versions = 5
  }
}


# Associate each certificate with the respective control plane
resource "konnect_gateway_data_plane_client_certificate" "cp_dp_cert" {
  for_each         = vault_kv_secret_v2.cp_cert_kv_secret
  cert             = each.value.data.tls_crt
  control_plane_id = var.control_planes[each.key].id
}
