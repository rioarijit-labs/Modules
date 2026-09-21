# HTTPS-only inbound from the internet plus the default explicit deny-all.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name              = "nsg-defaults"
  location          = "westeurope"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"

  security_rules = {
    allow_https_inbound = {
      name                       = "AllowHttpsInbound"
      access                     = "Allow"
      direction                  = "Inbound"
      priority                   = 100
      protocol                   = "Tcp"
      source_address_prefix      = "Internet"
      source_port_range          = "*"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "443"
    }
  }
}
