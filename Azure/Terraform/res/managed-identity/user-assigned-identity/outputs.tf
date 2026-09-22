output "resource_id" {
  description = "Resource ID of the managed identity. Pass this to another module's user_assigned_identity_resource_ids."
  value       = module.user_assigned_identity.resource_id
}

output "name" {
  description = "Name of the managed identity."
  value       = module.user_assigned_identity.resource_name
}

output "principal_id" {
  description = "Principal (object) ID, used in role assignments."
  value       = module.user_assigned_identity.principal_id
}

output "client_id" {
  description = "Client (application) ID, used by application code (e.g. DefaultAzureCredential, Kubernetes workload identity annotations)."
  value       = module.user_assigned_identity.client_id
}
