output "resource_id" {
  description = "Resource ID of the Front Door profile."
  value       = module.front_door_profile.resource_id
}

output "name" {
  description = "Name of the profile."
  value       = var.name
}
