locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)
  has_vnet            = var.infrastructure_subnet_resource_id != null

  diagnostic_settings = var.diagnostics == null ? {} : {
    default = {
      workspace_resource_id = var.diagnostics.workspace_resource_id
    }
  }
}

module "managed_environment" {
  source  = "Azure/avm-res-app-managedenvironment/azurerm"
  version = "0.5.0"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  parent_id           = var.resource_group_id
  tags                = var.tags

  infrastructure_subnet_id       = var.infrastructure_subnet_resource_id
  internal_load_balancer_enabled = local.has_vnet && var.internal
  zone_redundancy_enabled        = local.has_vnet && var.zone_redundant
  public_network_access_enabled  = var.public_network_access_enabled

  # Workload profiles environment with the pay-per-use Consumption profile
  workload_profiles = [
    {
      name                  = "Consumption"
      workload_profile_type = "Consumption"
    },
  ]

  # Logs go through diagnostic settings to Log Analytics, so no workspace shared key is passed around
  app_logs_configuration = var.diagnostics == null ? null : {
    destination = "azure-monitor"
  }
  diagnostic_settings = local.diagnostic_settings
}
