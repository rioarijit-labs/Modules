output "resource_id" {
  description = "Resource ID of the app."
  value       = module.app_service.resource_id
}

output "name" {
  description = "Name of the app."
  value       = module.app_service.name
}

output "default_hostname" {
  description = "Default host name of the app, e.g. <name>.azurewebsites.net."
  value       = "${var.name}.azurewebsites.net"
}

output "system_assigned_mi_principal_id" {
  description = "Principal ID of the system-assigned identity."
  value       = module.app_service.system_assigned_mi_principal_id
}
