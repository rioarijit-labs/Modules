# Standard namespace with a telemetry event hub and a data sender role.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name              = "evh-defaults-0001"
  location          = "westeurope"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"

  event_hubs = {
    telemetry = {
      partition_count           = 4
      message_retention_in_days = 3
    }
  }

  role_assignments = {
    telemetry_sender = {
      role_definition_id_or_name = "Azure Event Hubs Data Sender"
      principal_id               = "00000000-0000-0000-0000-000000000001"
      principal_type             = "ServicePrincipal"
    }
  }
}
