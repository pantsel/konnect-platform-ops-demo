output "id" {
  description = "Contains a unique identifier used for this resource"
  value       = konnect_portal_page.this.id
}

output "created_at" {
  description = "An ISO-8601 timestamp representation of entity creation date"
  value       = konnect_portal_page.this.created_at
}

output "updated_at" {
  description = "An ISO-8601 timestamp representation of entity update date"
  value       = konnect_portal_page.this.updated_at
}

output "content" {
  description = "The renderable markdown content of a page in a portal"
  value       = konnect_portal_page.this.content
}

output "portal_id" {
  description = "The Portal identifier"
  value       = konnect_portal_page.this.portal_id
}

output "slug" {
  description = "The slug of a page in a portal"
  value       = konnect_portal_page.this.slug
}

output "description" {
  description = "Description of the portal page"
  value       = konnect_portal_page.this.description
}

output "parent_page_id" {
  description = "Parent page ID for hierarchical organization"
  value       = konnect_portal_page.this.parent_page_id
}

output "status" {
  description = "Whether the resource is visible on a given portal"
  value       = konnect_portal_page.this.status
}

output "title" {
  description = "The title of a page in a portal"
  value       = konnect_portal_page.this.title
}

output "visibility" {
  description = "Whether a page is publicly accessible to non-authenticated users"
  value       = konnect_portal_page.this.visibility
}
