output "resource_id" {
  description = "Resource ID of the App Service plan."
  value       = module.app_service_plan.resource_id
}

output "name" {
  description = "Name of the App Service plan."
  value       = module.app_service_plan.name
}
