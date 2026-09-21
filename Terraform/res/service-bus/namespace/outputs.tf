output "resource_id" {
  description = "Resource ID of the namespace."
  value       = module.namespace.resource_id
}

output "name" {
  description = "Name of the namespace."
  value       = var.name
}

output "service_bus_endpoint" {
  description = "Service Bus endpoint URL, e.g. https://<name>.servicebus.windows.net/."
  value       = "https://${var.name}.servicebus.windows.net/"
}
