locals {

  kv_mount = "konnect"

  cert = {
    allowed_uses = [
      "cert_signing",
      "crl_signing",
      "encipher_only",
      "server_auth",
      "client_auth"
    ],
    subject = {
      organization = "ACME Inc"
      country      = "EU"
    },
  }
}

# Fetch the private key from the vault
# We will use this private key to sign the Data Plane certificate
data "vault_kv_secret_v2" "tls" {
  mount = "konnect"
  name  = "tls"
}
