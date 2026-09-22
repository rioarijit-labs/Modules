# Single-region account with one SQL database, a shared-throughput container and a data reader role for an app identity.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name              = "cosmos-defaults-0001"
  location          = "westeurope"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"

  sql_databases = {
    catalog = {
      throughput = 400
      containers = {
        products = {
          partition_key_paths = ["/category"]
          default_ttl_seconds = -1
        }
      }
    }
  }

  data_role_assignments = {
    app_reader = {
      principal_id = "00000000-0000-0000-0000-000000000001"
      role         = "Reader"
    }
  }
}
