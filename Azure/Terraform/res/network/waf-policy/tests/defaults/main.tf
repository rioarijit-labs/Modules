# Prevention mode with the OWASP 3.2 rule set and a custom rule blocking a source range.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name              = "waf-defaults"
  location          = "westeurope"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"

  custom_rules = {
    block_test_range = {
      priority = 1
      action   = "Block"
      match_conditions = [
        {
          match_variables = [
            { variable_name = "RemoteAddr" }
          ]
          operator     = "IPMatch"
          match_values = ["198.51.100.0/24"]
        }
      ]
    }
  }
}
