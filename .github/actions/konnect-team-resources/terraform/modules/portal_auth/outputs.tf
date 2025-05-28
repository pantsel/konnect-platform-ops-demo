output "portal_auth" {
  description = "The portal authentication configuration"
  value       = konnect_portal_auth.this
}

output "portal_id" {
  description = "The Portal identifier"
  value       = konnect_portal_auth.this.portal_id
}

output "oidc_config" {
  description = "Configuration properties for an OpenID Connect Identity Provider"
  value       = konnect_portal_auth.this.oidc_config
}
