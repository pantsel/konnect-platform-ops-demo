output "api_id" {
  description = "The UUID API identifier."
  value       = konnect_api_publication.this.api_id
}

output "portal_id" {
  description = "The Portal identifier."
  value       = konnect_api_publication.this.portal_id
}

output "auth_strategy_ids" {
  description = "The auth strategy the API enforces for applications in the portal."
  value       = konnect_api_publication.this.auth_strategy_ids
}

output "auto_approve_registrations" {
  description = "Whether the application registration auto approval on this portal for the api is enabled."
  value       = konnect_api_publication.this.auto_approve_registrations
}

output "visibility" {
  description = "The visibility of the API in the portal."
  value       = konnect_api_publication.this.visibility
}

output "created_at" {
  description = "An ISO-8601 timestamp representation of entity creation date."
  value       = konnect_api_publication.this.created_at
}

output "updated_at" {
  description = "An ISO-8601 timestamp representation of entity update date."
  value       = konnect_api_publication.this.updated_at
}
