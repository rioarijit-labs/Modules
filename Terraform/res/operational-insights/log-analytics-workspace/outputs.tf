output "resource_id" {
  description = "Resource ID of the workspace. Pass it as diagnostics.workspace_resource_id to the other modules."
  value       = module.workspace.resource_id
}

output "name" {
  description = "Name of the workspace."
  value       = var.name
}
