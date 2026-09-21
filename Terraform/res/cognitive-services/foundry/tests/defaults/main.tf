# Foundry resource with one model deployment and one project, Entra ID only, no public access.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name              = "aif-defaults-0001"
  location          = "swedencentral"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"

  model_deployments = {
    "gpt-4o" = {
      model = {
        format  = "OpenAI"
        name    = "gpt-4o"
        version = "2024-11-20"
      }
      sku = {
        name     = "GlobalStandard"
        capacity = 10
      }
    }
  }

  projects = {
    "proj-default" = {
      display_name = "Default project"
      description  = "Project created by the module test."
    }
  }
}
