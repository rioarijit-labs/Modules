locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)
}

module "workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.5.1"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags

  log_analytics_workspace_sku                        = var.sku_name
  log_analytics_workspace_retention_in_days          = var.retention_in_days
  log_analytics_workspace_daily_quota_gb             = var.daily_quota_gb
  log_analytics_workspace_internet_ingestion_enabled = tostring(var.internet_ingestion_enabled)
  log_analytics_workspace_internet_query_enabled     = tostring(var.internet_query_enabled)

  role_assignments = var.role_assignments
}
