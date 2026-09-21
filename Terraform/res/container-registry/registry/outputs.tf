output "resource_id" {
  description = "Resource ID of the registry."
  value       = module.registry.resource_id
}

output "name" {
  description = "Name of the registry."
  value       = module.registry.name
}

output "login_server" {
  description = "Login server, e.g. <name>.azurecr.io."
  value       = module.registry.login_server
}
