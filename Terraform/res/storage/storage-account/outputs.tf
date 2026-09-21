output "resource_id" {
  description = "Resource ID of the storage account."
  value       = module.storage_account.resource_id
}

output "name" {
  description = "Name of the storage account."
  value       = module.storage_account.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint URL. Empty when the account has no blob service."
  value       = try("https://${module.storage_account.fqdn["blob"]}/", "")
}
