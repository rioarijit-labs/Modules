locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  apis = {
    for api_name, api in var.apis : api_name => {
      display_name          = api.display_name
      path                  = api.path
      protocols             = ["https"]
      subscription_required = api.subscription_required
      import = {
        content_format = "openapi-link"
        content_value  = api.open_api_spec_url
      }
    }
  }

  private_endpoints = var.private_endpoint == null ? {} : {
    default = {
      subnet_resource_id            = var.private_endpoint.subnet_resource_id
      private_dns_zone_resource_ids = toset(var.private_endpoint.private_dns_zone_resource_ids)
      tags                          = var.tags
    }
  }
}

module "api_management" {
  source  = "Azure/avm-res-apimanagement-service/azurerm"
  version = "0.9.0"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
  publisher_email     = var.publisher_email
  publisher_name      = var.publisher_name
  sku_name            = var.sku

  virtual_network_type          = var.virtual_network_type
  virtual_network_subnet_id     = var.subnet_resource_id
  public_network_access_enabled = var.public_network_access_enabled

  apis              = local.apis
  private_endpoints = local.private_endpoints
  managed_identities = {
    system_assigned = var.enable_system_assigned_identity
  }
  role_assignments = var.role_assignments
}
