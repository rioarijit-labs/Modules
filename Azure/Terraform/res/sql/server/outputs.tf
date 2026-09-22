output "resource_id" {
  description = "Resource ID of the server."
  value       = module.sql_server.resource_id
}

output "name" {
  description = "Name of the server."
  value       = var.name
}

output "fully_qualified_domain_name" {
  description = "Fully qualified domain name, e.g. <name>.database.windows.net."
  value       = "${var.name}.database.windows.net"
}

output "system_assigned_mi_principal_id" {
  description = "Principal ID of the system-assigned identity. Empty when not enabled."
  value       = try(module.sql_server.identity.principal_id, "")
}
