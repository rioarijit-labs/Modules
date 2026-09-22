output "resource_id" {
  description = "Resource ID of the Foundry resource."
  value       = module.foundry.resource_id
}

output "name" {
  description = "Name of the Foundry resource."
  value       = module.foundry.name
}

output "endpoint" {
  description = "Endpoint of the Foundry resource."
  value       = module.foundry.endpoint
}

output "system_assigned_mi_principal_id" {
  description = "Principal ID of the system-assigned identity."
  value       = module.foundry.system_assigned_mi_principal_id
}

output "project_resource_ids" {
  description = "Resource IDs of the Foundry projects, keyed by project name."
  value       = { for project_name, project in azapi_resource.project : project_name => project.id }
}
