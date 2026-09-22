# Developer tier instance with one OpenAPI-imported API.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name              = "apim-defaults-0001"
  location          = "westeurope"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  publisher_email   = "api-team@example.com"
  publisher_name    = "Example Corp"

  apis = {
    orders_api = {
      display_name      = "Orders API"
      path              = "orders"
      open_api_spec_url = "https://example.com/openapi/orders.json"
    }
  }
}
