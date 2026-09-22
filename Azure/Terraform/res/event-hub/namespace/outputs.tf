output "resource_id" {
  description = "Resource ID of the namespace."
  value       = module.namespace.resource_id
}

output "name" {
  description = "Name of the namespace."
  value       = var.name
}
