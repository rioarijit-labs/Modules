output "resource_id" {
  description = "Resource ID of the environment. Pass it as environment_resource_id to the container-app module."
  value       = module.managed_environment.resource_id
}

output "name" {
  description = "Name of the environment."
  value       = module.managed_environment.name
}

output "default_domain" {
  description = "Default domain of the environment, the suffix of every app FQDN."
  value       = module.managed_environment.default_domain
}

output "static_ip_address" {
  description = "Static IP of the environment load balancer. Only set for internal environments in a VNet. Create a private DNS zone record for it."
  value       = module.managed_environment.static_ip_address
}
