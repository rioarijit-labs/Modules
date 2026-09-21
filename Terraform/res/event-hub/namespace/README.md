# Event Hubs namespace

Event Hubs namespace with event hubs. Wraps `Azure/avm-res-eventhub-namespace/azurerm` 0.1.0.

## Defaults

- **Standard** tier, one throughput unit
- Public network access **disabled**: private endpoints need Standard or Premium
- Shared access keys **disabled** (`local_authentication_enabled = false`): clients use Entra ID with `Azure Event Hubs Data Sender` / `Data Receiver`

## Notes

- Choose `partition_count` up front: it cannot be changed on Basic and Standard, and it caps consumer parallelism.
- **Consumer groups are not supported** by the underlying AVM module (0.1.0), so this wrapper cannot create them. Create them outside the module, or use the Bicep module in this repo.
- Basic has no private endpoint. For a cheap lab, set `sku_name` to `Basic` and `public_network_access_enabled` to `true`.
- Capture to storage or Data Lake is not exposed yet.

## Usage

```hcl
module "event_hubs" {
  source = "../../res/event-hub/namespace"

  name              = "evh-telemetry-001"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id

  event_hubs = {
    telemetry = { partition_count = 4 }
  }

  private_endpoint = {
    subnet_resource_id            = module.network.subnet_resource_ids["private_endpoints"]
    private_dns_zone_resource_ids = [module.service_bus_zone.resource_id]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): event hub with a sender role
