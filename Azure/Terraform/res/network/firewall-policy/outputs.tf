output "resource_id" {
  description = "Resource ID of the firewall policy. Pass this to the azure-firewall module's firewall_policy_resource_id."
  value       = module.firewall_policy.resource_id
}

output "name" {
  description = "Name of the firewall policy."
  value       = var.name
}
