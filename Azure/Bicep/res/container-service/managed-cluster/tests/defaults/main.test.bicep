metadata name = 'AKS - defaults'
metadata description = 'Private, Entra ID RBAC only cluster with a system pool, one user pool, workload identity and an admin group.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-managed-cluster-defaults'
  params: {
    name: 'aks-defaults'
    systemNodePool: {
      name: 'system'
      vmSize: 'Standard_D4s_v5'
      count: 3
      subnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-aks'
      availabilityZones: [1, 2, 3]
    }
    additionalNodePools: [
      {
        name: 'apps'
        vmSize: 'Standard_D8s_v5'
        count: 3
        enableAutoScaling: true
        minCount: 3
        maxCount: 10
        subnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-aks'
      }
    ]
    adminGroupObjectIds: ['00000000-0000-0000-0000-000000000001']
    monitoringWorkspaceResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.OperationalInsights/workspaces/log-example'
  }
}
