# One rule collection group with a network rule and an application rule.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name              = "fwpolicy-defaults"
  location          = "westeurope"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"

  rule_collection_groups = {
    spoke_egress = {
      priority = 200
      network_rules = {
        allow_dns = {
          priority              = 200
          protocols             = ["UDP"]
          source_addresses      = ["10.0.0.0/16"]
          destination_addresses = ["*"]
          destination_ports     = ["53"]
        }
      }
      application_rules = {
        allow_updates = {
          priority          = 201
          source_addresses  = ["10.0.0.0/16"]
          destination_fqdns = ["*.microsoft.com", "*.windowsupdate.com"]
          protocol_type     = "Https"
          protocol_port     = 443
        }
      }
    }
  }
}
