output "resource_id" {
  description = "Resource ID of the gateway."
  value       = module.application_gateway.resource_id
}

output "name" {
  description = "Name of the gateway."
  value       = var.name
}
