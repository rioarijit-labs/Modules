locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  # Ingress: internal HTTPS only by default
  ingress = var.disable_ingress ? null : {
    external_enabled           = var.ingress_external_enabled
    target_port                = var.target_port
    transport                  = "auto"
    allow_insecure_connections = false
    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }

  secrets = {
    for secret_name, secret in var.secrets : secret_name => {
      name                = secret_name
      key_vault_secret_id = secret.key_vault_secret_id
      identity            = secret.identity
    }
  }

  registries = var.registry == null ? [] : [{
    server   = var.registry.server
    identity = var.registry.identity_resource_id
  }]

  user_assigned_identity_resource_ids = var.registry == null ? var.user_assigned_identity_resource_ids : setunion(
    var.user_assigned_identity_resource_ids,
    [var.registry.identity_resource_id],
  )
}

module "container_app" {
  source  = "Azure/avm-res-app-containerapp/azurerm"
  version = "0.9.0"

  name                                  = var.name
  resource_group_name                   = local.resource_group_name
  resource_group_id                     = var.resource_group_id
  tags                                  = var.tags
  container_app_environment_resource_id = var.environment_resource_id
  workload_profile_name                 = "Consumption"

  template = {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
    containers = [{
      name   = var.container_name
      image  = var.image
      cpu    = var.cpu
      memory = var.memory
      env    = var.env
    }]
  }

  ingress    = local.ingress
  secrets    = local.secrets
  registries = local.registries

  managed_identities = {
    system_assigned            = var.enable_system_assigned_identity
    user_assigned_resource_ids = local.user_assigned_identity_resource_ids
  }
  role_assignments = var.role_assignments
}
