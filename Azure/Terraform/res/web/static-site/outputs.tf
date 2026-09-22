output "resource_id" {
  description = "Resource ID of the static web app."
  value       = module.static_site.resource_id
}

output "name" {
  description = "Name of the static web app."
  value       = module.static_site.name
}

output "default_hostname" {
  description = "Default host name. Empty until the underlying resource reports it; check the domains output for the full set including custom domains."
  value       = try(module.static_site.domains[0], "")
}
