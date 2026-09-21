output "resource_id" {
  description = "Resource ID of the virtual machine."
  value       = module.virtual_machine.resource_id
}

output "name" {
  description = "Name of the virtual machine."
  value       = module.virtual_machine.name
}

output "system_assigned_mi_principal_id" {
  description = "Principal ID of the system-assigned identity. Empty when not enabled."
  value       = try(module.virtual_machine.system_assigned_mi_principal_id, "")
}
