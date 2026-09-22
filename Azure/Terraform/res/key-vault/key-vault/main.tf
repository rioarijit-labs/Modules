data "azurerm_client_config" "current" {}

locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  private_endpoints = var.private_endpoint == null ? {} : {
    vault = {
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

module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.11.0"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = var.tags
  sku_name            = var.sku_name

  # Secure defaults: Azure RBAC only (no legacy access policies), soft delete, purge protection, private access
  legacy_access_policies_enabled = false
  soft_delete_retention_days     = var.soft_delete_retention_days
  purge_protection_enabled       = var.purge_protection_enabled
  public_network_access_enabled  = var.public_network_access_enabled
  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  private_endpoints   = local.private_endpoints
  diagnostic_settings = local.diagnostic_settings
  role_assignments    = var.role_assignments
}
