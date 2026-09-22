# Container registry

Azure Container Registry. Wraps `br/public:avm/res/container-registry/registry:0.13.1`.

## Defaults

- **Premium** tier, zone redundant: required for private endpoints and the firewall
- Public network access **disabled**, firewall default action `Deny`, `AzureServices` bypass
- Admin user **disabled**, anonymous pull **disabled**: use Entra ID and roles
- Export from the registry disabled, Microsoft Entra ID tokens accepted for ARM audience

## Roles

| Role | For |
|---|---|
| `AcrPull` | Container Apps, AKS, App Service pulling images |
| `AcrPush` | CI/CD pushing images |

## Notes

- With public access disabled, pushing from a hosted CI runner fails. Use a self-hosted runner in the VNet, ACR Tasks, or set `publicNetworkAccess` to `Enabled` with a firewall rule for the runner.
- Basic and Standard have no private endpoint. For a cheap lab, set `skuName` to `Basic` and `publicNetworkAccess` to `Enabled`.

## Usage

```bicep
module registry '../../res/container-registry/registry/main.bicep' = {
  name: 'acr'
  params: {
    name: 'acrexample001'
    privateEndpointSubnetResourceId: vnet.outputs.subnetResourceIds[1]
    privateDnsZoneResourceIds: [acrZone.outputs.resourceId]
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'AcrPull'
        principalId: pullIdentityPrincipalId
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): private endpoint and an AcrPull assignment
