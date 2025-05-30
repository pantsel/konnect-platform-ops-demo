output "id" {
  description = "The API document identifier"
  value       = konnect_api_document.this.id
}

output "api_id" {
  description = "The UUID API identifier"
  value       = konnect_api_document.this.api_id
}

output "content" {
  description = "Raw markdown content to display in your Portal"
  value       = konnect_api_document.this.content
}

output "labels" {
  description = "Labels store metadata of an entity"
  value       = konnect_api_document.this.labels
}

output "parent_document_id" {
  description = "API Documents may be rendered as a tree of files"
  value       = konnect_api_document.this.parent_document_id
}

output "slug" {
  description = "The slug is used in generated URLs to provide human readable paths"
  value       = konnect_api_document.this.slug
}

output "status" {
  description = "If status=published the document will be visible in your live portal"
  value       = konnect_api_document.this.status
}

output "title" {
  description = "The title of the document"
  value       = konnect_api_document.this.title
}

output "created_at" {
  description = "An ISO-8601 timestamp representation of entity creation date"
  value       = konnect_api_document.this.created_at
}

output "updated_at" {
  description = "An ISO-8601 timestamp representation of entity update date"
  value       = konnect_api_document.this.updated_at
}
