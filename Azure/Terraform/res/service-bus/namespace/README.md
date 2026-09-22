# Service Bus namespace

Service Bus namespace with queues, topics and subscriptions. Wraps `Azure/avm-res-servicebus-namespace/azurerm` 0.4.0.

## Defaults

- **Premium** tier, one messaging unit: required for private endpoints
- Public network access **disabled**
- Shared access keys **disabled** (`local_auth_enabled = false`): clients use Entra ID with `Azure Service Bus Data Sender` / `Data Receiver`
- TLS 1.2

## Tier trade-off

Premium is the only tier with private endpoints and it is billed per messaging unit, which is far more than Standard. For a cheap lab, set `sku_name` to `Standard` **and** `public_network_access_enabled` to `true`, and keep Entra ID only authentication.

## Notes

- `queues` and `topics` are maps keyed by the queue or topic name, and subscriptions are keyed by subscription name inside each topic.
- The upstream module does not expose zone redundancy separately; Premium namespaces use availability zones where the region supports them.

## Usage

```hcl
module "service_bus" {
  source = "../../res/service-bus/namespace"

  name              = "sb-orders-001"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id

  queues = {
    orders = { max_delivery_count = 5, dead_lettering_on_message_expiration = true }
  }

  topics = {
    events = {
      subscriptions = {
        billing       = {}
        notifications = {}
      }
    }
  }

  private_endpoint = {
    subnet_resource_id            = module.network.subnet_resource_ids["private_endpoints"]
    private_dns_zone_resource_ids = [module.service_bus_zone.resource_id]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): queue with dead-lettering, topic with two subscriptions
