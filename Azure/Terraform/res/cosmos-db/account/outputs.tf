output "resource_id" {
  description = "Resource ID of the Cosmos DB account."
  value       = module.cosmos_db_account.resource_id
}

output "name" {
  description = "Name of the Cosmos DB account."
  value       = module.cosmos_db_account.name
}

output "endpoint" {
  description = "SQL (Core) API endpoint URL."
  value       = "https://${var.name}.documents.azure.com:443/"
}

output "system_assigned_mi_principal_id" {
  description = "Principal ID of the system-assigned identity. Empty when not enabled."
  value       = try(module.cosmos_db_account.identity.principal_id, "")
}
