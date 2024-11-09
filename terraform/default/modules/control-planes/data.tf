# Fetch the private key from the vault
# We will use this private key to sign the Data Plane certificate
data "vault_kv_secret_v2" "tls" {
  mount = "konnect"
  name  = "tls"
}
