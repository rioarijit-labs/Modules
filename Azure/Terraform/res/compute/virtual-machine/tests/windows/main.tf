# Windows Server VM with a generated test password, Azure Monitor Agent and a data collection rule.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
provider "azurerm" {
  features {}
}

# The password is generated for the test only. Real deployments read it from Key Vault.
resource "random_password" "admin" {
  length  = 32
  special = true
}

module "test" {
  source = "../../"

  name               = "vm-windows-test"
  location           = "westeurope"
  resource_group_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  os_type            = "Windows"
  subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-workload"
  admin_password     = random_password.admin.result

  data_collection_rule_resource_ids = {
    default = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Insights/dataCollectionRules/dcr-example"
  }
}
