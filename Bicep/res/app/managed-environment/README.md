# Container Apps environment

Environment that hosts container apps. Wraps `br/public:avm/res/app/managed-environment:0.16.0`.

## Defaults

- Workload profiles environment with the pay-per-use `Consumption` profile
- Public network access **disabled**
- With a VNet, an **internal** load balancer: apps get private IPs
- Logs go to Log Analytics through diagnostic settings (`azure-monitor` destination), so no workspace shared key is passed around

## Networking

- The infrastructure subnet must be **delegated to `Microsoft.App/environments`**, be at least `/27`, and be dedicated to the environment.
- For an internal environment, create a private DNS zone named after the environment's `defaultDomain` output with a wildcard `*` A record pointing at the `staticIp` output, and link it to the networks that call the apps.
- Without a VNet the environment is external and gets a public endpoint, but `publicNetworkAccess` defaults to `Disabled`: set it to `Enabled` for a simple public lab, or add a private endpoint.

## Usage

```bicep
module environment '../../res/app/managed-environment/main.bicep' = {
  name: 'cae'
  params: {
    name: 'cae-example-001'
    infrastructureSubnetResourceId: vnet.outputs.subnetResourceIds[2]
    diagnosticsWorkspaceResourceId: logs.outputs.resourceId
  }
}
```

The `virtual-network` subnet for it needs `delegation: 'Microsoft.App/environments'`.

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): internal environment in a subnet with Log Analytics logging
