output "resource_id" {
  description = "Resource ID of the cluster."
  value       = module.managed_cluster.resource_id
}

output "name" {
  description = "Name of the cluster."
  value       = module.managed_cluster.name
}

output "control_plane_fqdn" {
  description = "Control plane FQDN. Only reachable from inside the network when enable_private_cluster is true."
  value       = try(module.managed_cluster.private_fqdn, module.managed_cluster.fqdn, "")
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL. Use this as the issuer in the managed-identity module's federated_identity_credentials for workload identity."
  value       = try(module.managed_cluster.oidc_issuer_profile_issuer_url, "")
}

output "system_assigned_mi_principal_id" {
  description = "Principal ID of the cluster's system-assigned identity. Empty when not enabled."
  value       = try(module.managed_cluster.identity_principal_id, "")
}

output "kubelet_identity_object_id" {
  description = "Principal (object) ID of the kubelet identity, used by nodes to pull images and manage load balancer/disk resources. Grant it AcrPull on your registry."
  value       = try(module.managed_cluster.kubelet_identity.object_id, "")
}
