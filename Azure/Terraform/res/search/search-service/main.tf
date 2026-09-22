locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  private_endpoints = var.private_endpoint == null ? {} : {
    search_service = {
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

module "search_service" {
  source  = "Azure/avm-res-search-searchservice/azurerm"
  version = "0.3.0"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
  sku                 = var.sku_name
  replica_count       = var.replica_count
  partition_count     = var.partition_count
  semantic_search_sku = var.semantic_search_sku

  # Secure defaults: private access, Entra ID only
  public_network_access_enabled = var.public_network_access_enabled
  local_authentication_enabled  = var.local_authentication_enabled

  private_endpoints   = local.private_endpoints
  diagnostic_settings = local.diagnostic_settings
  managed_identities = {
    system_assigned = var.enable_system_assigned_identity
  }
  role_assignments = var.role_assignments
}
