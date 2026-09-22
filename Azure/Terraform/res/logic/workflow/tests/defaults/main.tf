# HTTP-triggered workflow with a single response action.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name              = "logic-defaults"
  location          = "westeurope"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"

  triggers = {
    manual = {
      type = "Request"
      kind = "Http"
      inputs = {
        schema = {}
      }
    }
  }

  actions = {
    Response = {
      type = "Response"
      kind = "Http"
      inputs = {
        statusCode = 200
        body       = "OK"
      }
    }
  }
}
