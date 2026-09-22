# API Management

API gateway for publishing and securing APIs. Wraps `br/public:avm/res/api-management/service:0.14.4`.

## Defaults deliberately differ here

Unlike most modules in this repo, the default SKU is **Developer** (no SLA, no VNet integration), not the AVM module's own default of Premium. Premium (needed for VNet injection) runs roughly 50-60x the cost of Developer. Developer demonstrates the full pattern for a showcase or dev environment at a fraction of the cost; switch `skuName` to `Premium` or `PremiumV2` and set `virtualNetworkType` for a production, VNet-integrated deployment.

| SKU | VNet integration | SLA |
|---|---|---|
| `Developer` | No | No |
| `Basic`, `Standard`, `BasicV2`, `StandardV2` | No | Yes |
| `Premium`, `PremiumV2` | Yes (`virtualNetworkType`) | Yes, multi-region |

## Scope

This module provisions the gateway and imports APIs from an OpenAPI specification. It does not manage products, subscriptions, named values or custom policies beyond what the API import brings — add those through the portal, the Azure CLI, or by extending this module's `apis` wiring if you need policy XML applied at deploy time.

## Usage

```bicep
module apim '../../res/api-management/service/main.bicep' = {
  name: 'apim'
  params: {
    name: 'apim-example-001'
    publisherEmail: 'api-team@example.com'
    publisherName: 'Example Corp'
    apis: [
      {
        name: 'orders-api'
        displayName: 'Orders API'
        path: 'orders'
        openApiSpecUrl: 'https://example.com/openapi/orders.json'
      }
    ]
  }
}
```

For a private, production deployment:

```bicep
skuName: 'PremiumV2'
virtualNetworkType: 'Internal'
subnetResourceId: vnet.outputs.subnetResourceIds['apim']
publicNetworkAccess: 'Disabled'
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): Developer tier with one imported API
