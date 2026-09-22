output "resource_id" {
  description = "Resource ID of the managed instance."
  value       = module.managed_instance.resource_id
}

output "name" {
  description = "Name of the managed instance."
  value       = var.name
}

output "system_assigned_mi_principal_id" {
  description = "Principal ID of the system-assigned identity. Grant it the Entra ID \"Directory Readers\" role so Entra logins work."
  value       = try(module.managed_instance.identity.principal_id, "")
}
