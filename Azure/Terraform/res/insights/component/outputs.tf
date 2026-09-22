output "resource_id" {
  description = "Resource ID of the Application Insights component."
  value       = module.application_insights.resource_id
}

output "name" {
  description = "Name of the component."
  value       = module.application_insights.name
}

output "connection_string" {
  description = "Connection string. Not a secret in the traditional sense (it identifies the ingestion endpoint, it does not grant read access), but avoid logging it unnecessarily. Set as an app setting on the app that sends telemetry."
  value       = module.application_insights.connection_string
}
