locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  private_endpoints = var.private_endpoint == null ? {} : {
    default = {
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

module "redis" {
  source  = "Azure/avm-res-cache-redis/azurerm"
  version = "0.4.0"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
  sku_name            = var.sku_name
  capacity            = var.capacity
  shard_count         = var.sku_name == "Premium" ? var.shard_count : null

  # Secure defaults: Entra ID only, TLS 1.2, private access
  minimum_tls_version                = "1.2"
  enable_non_ssl_port                = false
  access_keys_authentication_enabled = var.access_keys_authentication_enabled
  public_network_access_enabled      = var.public_network_access_enabled

  private_endpoints   = local.private_endpoints
  diagnostic_settings = local.diagnostic_settings
  managed_identities = {
    system_assigned = var.enable_system_assigned_identity
  }
  role_assignments = var.role_assignments
}
