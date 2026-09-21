locals {
  private_endpoint_services = var.private_endpoint == null ? [] : tolist(var.private_endpoint.services)

  private_endpoints = {
    for service in local.private_endpoint_services : service => {
      subnet_resource_id = var.private_endpoint.subnet_resource_id
      subresource_name   = service
      tags               = var.tags
      private_dns_zone_resource_ids = contains(keys(var.private_endpoint.private_dns_zone_resource_ids), service) ? [
        var.private_endpoint.private_dns_zone_resource_ids[service],
      ] : []
    }
  }

  containers = {
    for container_name in var.container_names : container_name => {
      name          = container_name
      public_access = "None"
    }
  }

  diagnostic_settings = var.diagnostics == null ? {} : {
    default = {
      workspace_resource_id = var.diagnostics.workspace_resource_id
      metrics               = [{ category = "Transaction" }, { category = "Capacity" }]
    }
  }
}

module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.10.0"

  name                     = var.name
  location                 = var.location
  parent_id                = var.resource_group_id
  tags                     = var.tags
  account_kind             = var.kind
  account_tier             = split("_", var.sku_name)[0]
  account_replication_type = split("_", var.sku_name)[1]
  is_hns_enabled           = var.enable_hierarchical_namespace

  # Secure defaults, stated explicitly so a change of the upstream default cannot weaken them
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  public_network_access_enabled   = var.public_network_access_enabled
  network_rules                   = { default_action = "Deny", bypass = ["AzureServices"] }
  blob_properties = {
    delete_retention_policy           = { enabled = true, days = var.soft_delete_retention_days }
    container_delete_retention_policy = { enabled = true, days = var.soft_delete_retention_days }
  }

  containers        = local.containers
  private_endpoints = local.private_endpoints

  diagnostic_settings_storage_account = local.diagnostic_settings

  managed_identities = {
    system_assigned            = var.enable_system_assigned_identity
    user_assigned_resource_ids = var.user_assigned_identity_resource_ids
  }
  role_assignments = var.role_assignments
}
