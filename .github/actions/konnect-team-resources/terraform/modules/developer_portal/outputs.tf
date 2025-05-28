output "portal" {
  description = "The developer portal configuration"
  value       = konnect_portal.this
}

output "id" {
  description = "The portal identifier"
  value       = konnect_portal.this.id
}
