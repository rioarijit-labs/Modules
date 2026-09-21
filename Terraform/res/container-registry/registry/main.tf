locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)
  is_premium          = var.sku_name == "Premium"

  private_endpoints = var.private_endpoint == null ? {} : {
    registry = {
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

module "registry" {
  source  = "Azure/avm-res-containerregistry-registry/azurerm"
  version = "0.8.0"

  name                    = var.name
  location                = var.location
  resource_group_name     = local.resource_group_name
  tags                    = var.tags
  sku                     = var.sku_name
  zone_redundancy_enabled = local.is_premium && var.zone_redundancy_enabled

  # Secure defaults: no admin user, no anonymous pull, private access
  admin_enabled                 = false
  anonymous_pull_enabled        = false
  export_policy_enabled         = false
  public_network_access_enabled = var.public_network_access_enabled
  network_rule_bypass_option    = "AzureServices"
  # The firewall rule set is a Premium feature
  network_rule_set = local.is_premium ? { default_action = "Deny" } : null

  private_endpoints   = local.private_endpoints
  diagnostic_settings = local.diagnostic_settings
  managed_identities = {
    system_assigned = var.enable_system_assigned_identity
  }
  role_assignments = var.role_assignments
}
