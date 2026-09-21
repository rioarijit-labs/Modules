output "resource_id" {
  description = "Resource ID of the network security group."
  value       = module.network_security_group.resource_id
}

output "name" {
  description = "Name of the network security group."
  value       = module.network_security_group.name
}
