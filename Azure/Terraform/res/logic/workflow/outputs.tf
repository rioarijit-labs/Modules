output "resource_id" {
  description = "Resource ID of the workflow."
  value       = module.workflow.resource_id
}

output "name" {
  description = "Name of the workflow."
  value       = var.name
}

output "system_assigned_mi_principal_id" {
  description = "Principal ID of the system-assigned identity. Empty when not enabled."
  value       = try(module.workflow.system_assigned_mi_principal_id, "")
}
