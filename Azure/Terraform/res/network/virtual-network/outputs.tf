output "resource_id" {
  description = "Resource ID of the virtual network."
  value       = module.virtual_network.resource_id
}

output "name" {
  description = "Name of the virtual network."
  value       = module.virtual_network.name
}

output "subnet_resource_ids" {
  description = "Resource IDs of the subnets, keyed by the same keys as the subnets variable."
  value       = { for key, subnet in module.virtual_network.subnets : key => subnet.resource_id }
}
