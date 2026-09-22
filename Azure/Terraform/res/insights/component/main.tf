locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)
}

module "application_insights" {
  source  = "Azure/avm-res-insights-component/azurerm"
  version = "0.4.0"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
  workspace_id        = var.log_analytics_workspace_id
  application_type    = var.application_type
  retention_in_days   = var.retention_in_days
  sampling_percentage = var.sampling_percentage
  disable_ip_masking  = false

  internet_ingestion_enabled    = var.internet_ingestion_enabled
  internet_query_enabled        = var.internet_query_enabled
  local_authentication_disabled = var.local_authentication_disabled

  role_assignments = var.role_assignments
}
