# Premium namespace with an orders queue and an events topic with two subscriptions.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name              = "sb-defaults-0001"
  location          = "westeurope"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"

  queues = {
    orders = {
      max_delivery_count                   = 5
      lock_duration                        = "PT1M"
      dead_lettering_on_message_expiration = true
    }
  }

  topics = {
    events = {
      subscriptions = {
        billing       = { max_delivery_count = 10 }
        notifications = {}
      }
    }
  }
}
