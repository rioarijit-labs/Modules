output "resource_id" {
  description = "Resource ID of the private endpoint."
  value       = module.private_endpoint.resource_id
}

output "name" {
  description = "Name of the private endpoint."
  value       = module.private_endpoint.name
}
