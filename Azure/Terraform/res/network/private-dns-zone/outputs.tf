output "resource_id" {
  description = "Resource ID of the private DNS zone."
  value       = module.private_dns_zone.resource_id
}

output "name" {
  description = "Name of the private DNS zone."
  value       = module.private_dns_zone.name
}
