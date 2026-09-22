# Static Web App

Static Web App for a frontend, SPA or documentation site, with a managed global CDN. Wraps `br/public:avm/res/web/static-site:0.9.6`.

## Defaults deliberately differ from the rest of this repo

Every other module in this repo defaults `publicNetworkAccess` to disabled. This one defaults it to **enabled**, because a static site is usually built specifically to be reached over the public internet — the managed CDN, custom domains and staging-per-PR features all assume that. Set `publicNetworkAccess` to `Disabled` and provide `privateEndpointSubnetResourceId` for an internal-only site (Standard SKU only).

## Other defaults

- `Standard` SKU (Free has no private endpoint, no SLA and no custom auth providers)
- System-assigned managed identity **off** by default (most static sites don't call other Azure resources); turn it on if API functions need it

## Tier limits

Static Web Apps do not support a Log Analytics diagnostic settings resource at all (the underlying AVM module has no such property), so unlike every other module here there is no `diagnosticsWorkspaceResourceId` parameter. Use the app's built-in Application Insights integration if you need telemetry.

## Deploying content

Two ways, and they don't mix well:

1. **Native source control integration** — set `repository` (GitHub or Azure DevOps, plus a personal access token) and the resource itself sets up CI/CD. Simple, but the token becomes a secret this module has to pass through, and every environment repeats the OAuth-style setup.
2. **Deploy separately** (recommended) — leave `repository` unset and deploy with the [SWA CLI](https://azure.github.io/static-web-apps-cli/) or a GitHub Actions step using the app's deployment token (fetched at deploy time, not stored in Bicep). More flexible, and keeps no long-lived token in this module's parameters.

## Usage

```bicep
module site '../../res/web/static-site/main.bicep' = {
  name: 'site'
  params: {
    name: 'swa-docs-001'
    customDomainNames: ['docs.example.com']
    appSettings: {
      API_BASE_URL: 'https://api.example.com'
    }
  }
}
```

For an internal-only app:

```bicep
publicNetworkAccess: 'Disabled'
privateEndpointSubnetResourceId: vnet.outputs.subnetResourceIds[1]
privateDnsZoneResourceIds: [swaZone.outputs.resourceId]
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): public app with a custom domain and app settings
- [tests/private](tests/private/main.test.bicep): internal-only app with a private endpoint and source control integration
