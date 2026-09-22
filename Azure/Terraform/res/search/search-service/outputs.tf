output "resource_id" {
  description = "Resource ID of the search service."
  value       = module.search_service.resource_id
}

output "name" {
  description = "Name of the search service."
  value       = var.name
}

output "endpoint" {
  description = "Endpoint URL of the search service."
  value       = "https://${var.name}.search.windows.net"
}
