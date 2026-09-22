locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  private_endpoints = var.private_endpoint == null ? {} : {
    default = {
      subnet_resource_id            = var.private_endpoint.subnet_resource_id
      private_dns_zone_resource_ids = toset(var.private_endpoint.private_dns_zone_resource_ids)
      tags                          = var.tags
    }
  }

  custom_domains = {
    for domain_name in var.custom_domain_names : domain_name => {
      domain_name = domain_name
    }
  }
}

module "static_site" {
  source  = "Azure/avm-res-web-staticsite/azurerm"
  version = "0.6.2"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
  sku_tier            = var.sku
  sku_size            = var.sku

  public_network_access_enabled = var.public_network_access_enabled
  custom_domains                = local.custom_domains
  app_settings                  = var.app_settings

  private_endpoints = local.private_endpoints
  managed_identities = {
    system_assigned = var.enable_system_assigned_identity
  }
  role_assignments = var.role_assignments
}
