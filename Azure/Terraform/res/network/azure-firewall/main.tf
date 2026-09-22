locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  diagnostic_settings = var.diagnostics == null ? {} : {
    default = {
      workspace_resource_id = var.diagnostics.workspace_resource_id
    }
  }
}

module "azure_firewall" {
  source  = "Azure/avm-res-network-azurefirewall/azurerm"
  version = "0.4.0"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
  firewall_sku_name   = "AZFW_VNet"
  firewall_sku_tier   = var.sku_tier
  firewall_zones      = var.availability_zones

  firewall_ip_configuration = [
    {
      name                 = "default"
      subnet_id            = var.subnet_resource_id
      public_ip_address_id = var.public_ip_resource_id
    }
  ]
  firewall_policy_id = var.firewall_policy_resource_id

  diagnostic_settings = local.diagnostic_settings
  role_assignments    = var.role_assignments
}

# The module's own "resource" output is marked sensitive, so a plain data source reads the
# private IP back non-sensitively for the private_ip_address output below.
data "azurerm_firewall" "this" {
  name                = var.name
  resource_group_name = local.resource_group_name

  depends_on = [module.azure_firewall]
}
