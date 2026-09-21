locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  event_hubs = {
    for event_hub_name, event_hub in var.event_hubs : event_hub_name => {
      namespace_name      = var.name
      resource_group_name = local.resource_group_name
      partition_count     = event_hub.partition_count
      message_retention   = event_hub.message_retention_in_days
    }
  }

  private_endpoints = var.private_endpoint == null ? {} : {
    namespace = {
      subnet_resource_id            = var.private_endpoint.subnet_resource_id
      subresource_name              = "namespace"
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

module "namespace" {
  source  = "Azure/avm-res-eventhub-namespace/azurerm"
  version = "0.1.0"

  name                     = var.name
  location                 = var.location
  resource_group_name      = local.resource_group_name
  tags                     = var.tags
  sku                      = var.sku_name
  capacity                 = var.capacity
  auto_inflate_enabled     = var.auto_inflate_enabled
  maximum_throughput_units = var.maximum_throughput_units

  # Secure defaults: Entra ID only, private access
  local_authentication_enabled  = false
  public_network_access_enabled = var.public_network_access_enabled

  event_hubs          = local.event_hubs
  private_endpoints   = local.private_endpoints
  diagnostic_settings = local.diagnostic_settings
  managed_identities = {
    system_assigned = var.enable_system_assigned_identity
  }
  role_assignments = var.role_assignments
}
