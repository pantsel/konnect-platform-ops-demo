# Create a data plane client certificate using the private key from the vault
resource "tls_self_signed_cert" "demo_cp_cert" {
  private_key_pem = data.vault_kv_secret_v2.tls.data.tls_key

  subject {
    common_name  = "konnect-demo-cp"
    organization = "ACME Inc"
    country      = "EU"
  }

  validity_period_hours = 8760 // 1 year
  # early_renewal_hours = 8760 // Always renew the cert for demo purposes 1 year
  is_ca_certificate = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "encipher_only",
    "server_auth",
    "client_auth"
  ]
}

# Store the certificate in Vault
resource "vault_kv_secret_v2" "demo_cp_cert_kv_secret" {
  mount               = "konnect"
  name                = "tls/demo_cp"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      tls_crt = tls_self_signed_cert.demo_cp_cert.cert_pem,
    }
  )
  custom_metadata {
    max_versions = 5
  }
}

# Associate the certificate with the demo control plane
resource "konnect_gateway_data_plane_client_certificate" "demo_cp_dp_cert" {
  cert             = vault_kv_secret_v2.demo_cp_cert_kv_secret.data.tls_crt
  control_plane_id = konnect_gateway_control_plane.demo_cp.id
}