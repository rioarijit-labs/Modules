output "resource_id" {
  description = "Resource ID of the route table. Associate it with a subnet through the virtual-network module's route_table_resource_id."
  value       = module.route_table.resource_id
}

output "name" {
  description = "Name of the route table."
  value       = module.route_table.name
}
