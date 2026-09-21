locals {
  private_endpoints = var.private_endpoint == null ? {} : {
    sites = {
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

module "app_service" {
  source  = "Azure/avm-res-web-site/azurerm"
  version = "0.23.0"

  name                     = var.name
  location                 = var.location
  parent_id                = var.resource_group_id
  tags                     = var.tags
  kind                     = var.kind
  os_type                  = var.os_type
  service_plan_resource_id = var.service_plan_resource_id

  # Secure defaults: HTTPS only, TLS 1.2, no FTP, private access
  https_only                    = true
  public_network_access_enabled = var.public_network_access_enabled
  site_config = {
    always_on           = var.always_on
    minimum_tls_version = "1.2"
    ftps_state          = "Disabled"
    http2_enabled       = true
    health_check_path   = var.health_check_path
    linux_fx_version    = var.linux_fx_version
  }
  # Deployments use Entra ID / managed identity, not publishing credentials
  ftp_publish_basic_authentication_enabled = false
  scm_publish_basic_authentication_enabled = false

  app_settings              = var.app_settings
  virtual_network_subnet_id = var.virtual_network_subnet_resource_id

  managed_identities = {
    system_assigned            = var.enable_system_assigned_identity
    user_assigned_resource_ids = var.user_assigned_identity_resource_ids
  }
  private_endpoints   = local.private_endpoints
  diagnostic_settings = local.diagnostic_settings
  role_assignments    = var.role_assignments
}
