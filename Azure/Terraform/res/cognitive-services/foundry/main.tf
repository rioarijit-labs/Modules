locals {
  cognitive_deployments = {
    for deployment_name, deployment in var.model_deployments : deployment_name => {
      name  = deployment_name
      model = deployment.model
      scale = {
        type     = deployment.sku.name
        capacity = deployment.sku.capacity
      }
    }
  }

  private_endpoints = var.private_endpoint == null ? {} : {
    account = {
      subnet_resource_id            = var.private_endpoint.subnet_resource_id
      private_dns_zone_resource_ids = toset(var.private_endpoint.private_dns_zone_resource_ids)
      tags                          = var.tags
    }
  }

  diagnostic_settings = var.diagnostics == null ? {} : {
    default = {
      workspace_resource_id = var.diagnostics.workspace_resource_id
    }
  }
}

module "foundry" {
  source  = "Azure/avm-res-cognitiveservices-account/azurerm"
  version = "0.11.1"

  name                  = var.name
  location              = var.location
  parent_id             = var.resource_group_id
  tags                  = var.tags
  kind                  = "AIServices"
  sku_name              = var.sku_name
  custom_subdomain_name = coalesce(var.custom_subdomain_name, var.name)

  # Required for Foundry projects
  allow_project_management = true

  # Secure defaults: private access, Entra ID only
  public_network_access_enabled = var.public_network_access_enabled
  local_auth_enabled            = var.local_auth_enabled
  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = var.user_assigned_identity_resource_ids
  }
  cognitive_deployments = local.cognitive_deployments
  private_endpoints     = local.private_endpoints
  diagnostic_settings   = local.diagnostic_settings
  role_assignments      = var.role_assignments
}

resource "azapi_resource" "project" {
  for_each = var.projects

  type      = "Microsoft.CognitiveServices/accounts/projects@2025-06-01"
  name      = each.key
  parent_id = module.foundry.resource_id
  location  = var.location
  tags      = var.tags

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      displayName = coalesce(each.value.display_name, each.key)
      description = each.value.description == null ? "" : each.value.description
    }
  }
}
