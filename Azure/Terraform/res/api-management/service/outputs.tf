output "resource_id" {
  description = "Resource ID of the APIM instance."
  value       = module.api_management.resource_id
}

output "name" {
  description = "Name of the APIM instance."
  value       = var.name
}

output "system_assigned_mi_principal_id" {
  description = "Principal ID of the system-assigned identity. Empty when not enabled."
  value       = try(module.api_management.system_assigned_mi_principal_id, "")
}
