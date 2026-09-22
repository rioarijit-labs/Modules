output "resource_id" {
  description = "Resource ID of the container app."
  value       = module.container_app.resource_id
}

output "name" {
  description = "Name of the container app."
  value       = module.container_app.name
}

output "fqdn" {
  description = "Fully qualified domain name of the app. Empty when ingress is disabled."
  value       = try(module.container_app.fqdn_url, "")
}

output "system_assigned_mi_principal_id" {
  description = "Principal ID of the system-assigned identity. Empty when not enabled."
  value       = try(module.container_app.identity.principal_id, "")
}
