output "resource_id" {
  description = "Resource ID of the WAF policy. Pass this to the application-gateway module's firewall_policy_resource_id."
  value       = module.waf_policy.resource_id
}

output "name" {
  description = "Name of the WAF policy."
  value       = var.name
}
