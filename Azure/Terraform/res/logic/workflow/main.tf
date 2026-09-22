locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  logic_app_definition = {
    "$schema"      = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
    contentVersion = "1.0.0.0"
    parameters     = var.workflow_parameters
    triggers       = var.triggers
    actions        = var.actions
    outputs        = {}
  }
}

module "workflow" {
  source  = "Azure/avm-res-logic-workflow/azurerm"
  version = "0.1.2"

  name                 = var.name
  location             = var.location
  resource_group_id    = var.resource_group_id
  resource_group_name  = local.resource_group_name
  tags                 = var.tags
  state                = var.state
  logic_app_definition = local.logic_app_definition

  managed_identities = {
    system_assigned            = var.enable_system_assigned_identity
    user_assigned_resource_ids = var.user_assigned_identity_resource_ids
  }
  role_assignments = var.role_assignments
}
