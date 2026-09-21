# Event Hubs namespace

Event Hubs namespace with event hubs and consumer groups. Wraps `br/public:avm/res/event-hub/namespace:0.15.1`.

## Defaults

- **Standard** tier, one throughput unit, zone redundant
- Public network access **disabled**: private endpoints need Standard or Premium
- Shared access keys **disabled** (`disableLocalAuth`): clients use Entra ID with `Azure Event Hubs Data Sender` / `Data Receiver`
- TLS 1.2

## Notes

- Choose `partitionCount` up front: it cannot be changed on Basic and Standard, and it caps consumer parallelism.
- Basic has no private endpoint. For a cheap lab, set `skuName` to `Basic` and `publicNetworkAccess` to `Enabled`.
- Capture to storage or Data Lake is not exposed yet. Add it to `eventHubType` when needed.

## Usage

```bicep
module eventHubs '../../res/event-hub/namespace/main.bicep' = {
  name: 'evh'
  params: {
    name: 'evh-telemetry-001'
    eventHubs: [
      {
        name: 'telemetry'
        partitionCount: 4
        consumergroups: [{ name: 'analytics' }]
      }
    ]
    privateEndpointSubnetResourceId: vnet.outputs.subnetResourceIds[1]
    privateDnsZoneResourceIds: [serviceBusZone.outputs.resourceId]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): event hub with two consumer groups and a sender role
