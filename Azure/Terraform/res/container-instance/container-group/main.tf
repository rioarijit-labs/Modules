locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  containers = {
    for container_name, container in var.containers : container_name => {
      image  = container.image
      cpu    = container.cpu
      memory = container.memory
      ports = [
        for port in container.ports : {
          port     = port
          protocol = "TCP"
        }
      ]
      commands                     = container.commands
      environment_variables        = container.environment_variables
      secure_environment_variables = container.secure_environment_variables
      volumes                      = {}
    }
  }

  diagnostics_log_analytics = var.log_analytics_workspace_id == "" ? null : {
    workspace_id  = var.log_analytics_workspace_id
    workspace_key = var.log_analytics_workspace_key
  }
}

module "container_group" {
  source  = "Azure/avm-res-containerinstance-containergroup/azurerm"
  version = "0.2.0"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
  os_type             = var.os_type
  restart_policy      = var.restart_policy
  containers          = local.containers
  # No public IP: the group lives only in the subnet
  subnet_ids                = [var.subnet_resource_id]
  diagnostics_log_analytics = local.diagnostics_log_analytics

  managed_identities = {
    system_assigned            = var.enable_system_assigned_identity
    user_assigned_resource_ids = var.user_assigned_identity_resource_ids
  }
  role_assignments = var.role_assignments
}
