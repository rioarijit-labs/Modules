# App Service

Secure-by-default web app or function app. Wraps `br/public:avm/res/web/site:0.24.0`.

## Defaults

- HTTPS only, TLS 1.2, HTTP/2, FTPS disabled
- Basic publishing credentials (SCM and FTP) **disabled**: deploy with Entra ID
- System-assigned managed identity
- Public network access **disabled**. Reach the app through a private endpoint, or set `publicNetworkAccess` to `Enabled` for an internet-facing app.

## Networking

- **Outbound**: set `virtualNetworkSubnetResourceId` to a subnet delegated to `Microsoft.Web/serverFarms` (regional VNet integration).
- **Inbound**: set `privateEndpointSubnetResourceId` and the `privatelink.azurewebsites.net` zone in `privateDnsZoneResourceIds`.

## Usage

```bicep
module app '../../res/web/app-service/main.bicep' = {
  name: 'app'
  params: {
    name: 'app-example-001'
    serverFarmResourceId: plan.outputs.resourceId
    linuxFxVersion: 'PYTHON|3.12'
    healthCheckPath: '/healthz'
    virtualNetworkSubnetResourceId: vnet.outputs.subnetResourceIds[2]
    appSettings: {
      STORAGE_BLOB_ENDPOINT: storage.outputs.primaryBlobEndpoint
    }
  }
}
```

Put secrets in Key Vault and reference them with `@Microsoft.KeyVault(...)` in `appSettings`.

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): Node app with VNet integration, health check and private endpoint
