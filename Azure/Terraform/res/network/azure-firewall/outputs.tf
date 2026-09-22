output "resource_id" {
  description = "Resource ID of the firewall."
  value       = module.azure_firewall.resource_id
}

output "name" {
  description = "Name of the firewall."
  value       = var.name
}

output "private_ip_address" {
  description = "Private IP address of the firewall. Point a route table's default route at this address."
  value       = try(data.azurerm_firewall.this.ip_configuration[0].private_ip_address, "")
}
