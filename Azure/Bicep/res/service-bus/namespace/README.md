# Service Bus namespace

Service Bus namespace with queues, topics and subscriptions. Wraps `br/public:avm/res/service-bus/namespace:0.17.1`.

## Defaults

- **Premium** tier, one messaging unit, zone redundant: required for private endpoints
- Public network access **disabled**
- Shared access keys **disabled** (`disableLocalAuth`): clients use Entra ID with `Azure Service Bus Data Sender` / `Data Receiver`
- TLS 1.2

## Tier trade-off

Premium is the only tier with private endpoints and it is billed per messaging unit, which is far more than Standard. For a cheap lab, set `skuName` to `Standard` **and** `publicNetworkAccess` to `Enabled`, and keep Entra ID only authentication.

## Usage

```bicep
module serviceBus '../../res/service-bus/namespace/main.bicep' = {
  name: 'sb'
  params: {
    name: 'sb-orders-001'
    queues: [
      { name: 'orders', maxDeliveryCount: 5, deadLetteringOnMessageExpiration: true }
    ]
    topics: [
      {
        name: 'events'
        subscriptions: [{ name: 'billing' }, { name: 'notifications' }]
      }
    ]
    privateEndpointSubnetResourceId: vnet.outputs.subnetResourceIds[1]
    privateDnsZoneResourceIds: [serviceBusZone.outputs.resourceId]
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Azure Service Bus Data Sender'
        principalId: app.outputs.systemAssignedMIPrincipalId
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): queue with dead-lettering, topic with two subscriptions
