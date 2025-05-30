output "id" {
  description = "Contains a unique identifier used for this resource."
  value       = konnect_api_implementation.this.id
}

output "api_id" {
  description = "The UUID API identifier."
  value       = konnect_api_implementation.this.api_id
}

output "service" {
  description = "A Gateway service that implements an API."
  value       = konnect_api_implementation.this.service
}

output "created_at" {
  description = "An ISO-8601 timestamp representation of entity creation date."
  value       = konnect_api_implementation.this.created_at
}

output "updated_at" {
  description = "An ISO-8601 timestamp representation of entity update date."
  value       = konnect_api_implementation.this.updated_at
}
