locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  deny_all_inbound_rule = {
    deny_all_inbound = {
      name                       = "DenyAllInbound"
      access                     = "Deny"
      direction                  = "Inbound"
      priority                   = 4096
      protocol                   = "*"
      description                = "Deny all inbound traffic not matched by a higher-priority rule."
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "*"
    }
  }
  security_rules = var.deny_all_inbound ? merge(var.security_rules, local.deny_all_inbound_rule) : var.security_rules

  diagnostic_settings = var.diagnostics == null ? {} : {
    default = {
      workspace_resource_id = var.diagnostics.workspace_resource_id
    }
  }
}

module "network_security_group" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
  security_rules      = local.security_rules
  diagnostic_settings = local.diagnostic_settings
}
