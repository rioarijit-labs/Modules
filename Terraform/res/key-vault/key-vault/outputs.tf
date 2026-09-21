output "resource_id" {
  description = "Resource ID of the vault."
  value       = module.key_vault.resource_id
}

output "name" {
  description = "Name of the vault."
  value       = module.key_vault.name
}

output "uri" {
  description = "URI of the vault, e.g. for Key Vault references."
  value       = module.key_vault.uri
}
