# Azure Functions

Function app on a Consumption or Premium/Dedicated plan. Wraps `br/public:avm/res/web/site:0.24.0`.

## Keyless storage, on purpose

Functions needs a storage account (`AzureWebJobsStorage`) for its runtime — triggers, bindings and state. Instead of a connection string or access key, this module wires it through **identity-based connection**: `AzureWebJobsStorage__accountName` plus `AzureWebJobsStorage__credential=managedidentity`. You still have to:

1. Create the storage account yourself, with the [storage-account](../../storage/storage-account) module.
2. Grant this app's identity `Storage Blob Data Owner`, `Storage Queue Data Contributor` and `Storage Table Data Contributor` on it, through that module's `roleAssignments`, using this module's `systemAssignedMIPrincipalId` output.

No key or connection string ever appears in app settings.

## Hosting plan

This module takes `serverFarmResourceId` rather than creating a plan itself, so you choose the trade-off explicitly with the [app-service-plan](../app-service-plan) module:

- **Consumption**: `skuName: 'Y1'`. Pay per execution, scales to zero, has cold start, and cannot use regional VNet integration for inbound traffic (outbound VNet integration works).
- **Premium** (`EP1`-`EP3`) or a **Dedicated** plan: no cold start, full VNet integration, higher cost.

## Defaults

- HTTPS only, TLS 1.2, no FTP, basic publishing credentials disabled
- Public network access **disabled**
- System-assigned managed identity, used for the storage connection above

## Usage

```bicep
module storage '../../res/storage/storage-account/main.bicep' = {
  name: 'func-storage'
  params: {
    name: 'stfuncexample001'
    privateEndpointSubnetResourceId: vnet.outputs.subnetResourceIds[1]
  }
}

module plan '../../res/web/app-service-plan/main.bicep' = {
  name: 'func-plan'
  params: {
    name: 'asp-func-consumption'
    skuName: 'Y1'
  }
}

module functionApp '../../res/web/function-app/main.bicep' = {
  name: 'func'
  params: {
    name: 'func-orders-001'
    serverFarmResourceId: plan.outputs.resourceId
    workerRuntime: 'node'
    runtimeVersion: '20'
    storageAccountName: storage.outputs.name
    virtualNetworkSubnetResourceId: vnet.outputs.subnetResourceIds[2]
  }
}

module storageAccess '../../res/storage/storage-account/main.bicep' = {
  name: 'func-storage-access'
  params: {
    name: storage.outputs.name
    roleAssignments: [
      { roleDefinitionIdOrName: 'Storage Blob Data Owner', principalId: functionApp.outputs.systemAssignedMIPrincipalId, principalType: 'ServicePrincipal' }
      { roleDefinitionIdOrName: 'Storage Queue Data Contributor', principalId: functionApp.outputs.systemAssignedMIPrincipalId, principalType: 'ServicePrincipal' }
      { roleDefinitionIdOrName: 'Storage Table Data Contributor', principalId: functionApp.outputs.systemAssignedMIPrincipalId, principalType: 'ServicePrincipal' }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): Node app on Consumption with VNet integration and a private endpoint
