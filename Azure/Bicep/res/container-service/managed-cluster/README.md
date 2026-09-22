# AKS

Azure Kubernetes Service cluster. Wraps `br/public:avm/res/container-service/managed-cluster:0.14.0`.

## Defaults

- **Private API server** (`enablePrivateCluster: true`): no public endpoint. Reach it with `kubectl` from inside the VNet, over VPN/ExpressRoute, or through a jump host.
- **Entra ID RBAC only** (`disableLocalAccounts: true`, `aadProfile.enableAzureRBAC: true`): no local Kubernetes admin credentials. Cluster access is Azure RBAC role assignments (`Azure Kubernetes Service RBAC Cluster Admin`, `...Reader`, `...Writer`) plus `adminGroupObjectIds` for the Kubernetes-native admin binding.
- **Workload identity** on: pods get federated Entra ID identity with no stored secret.
- **Key Vault Secrets Provider** CSI driver on: pods can mount Key Vault secrets as files.
- Azure CNI (routable pod IPs) and Azure-native NetworkPolicy.
- `Standard` SKU tier (uptime SLA).

## Workload identity, tied to the managed-identity module

1. Deploy the cluster; read its `oidcIssuerUrl` output.
2. Create a [user-assigned-identity](../../managed-identity/user-assigned-identity) with a federated credential whose `issuer` is that URL and whose `subject` is `system:serviceaccount:<namespace>:<service-account-name>`.
3. Annotate the Kubernetes service account with the identity's client ID (`azure.workload.identity/client-id`), and label the pod spec `azure.workload.identity/use: "true"`.

No secret is stored anywhere in this chain.

## Scope

This is a base cluster: node pools, identity, network mode and monitoring. It does not configure ingress controllers, GitOps (Flux), Azure Policy add-on or a service mesh — the underlying AVM module supports all of these, add the relevant parameters when you need them.

## Usage

```bicep
module aks '../../res/container-service/managed-cluster/main.bicep' = {
  name: 'aks'
  params: {
    name: 'aks-platform-001'
    systemNodePool: {
      name: 'system'
      vmSize: 'Standard_D4s_v5'
      count: 3
      subnetResourceId: vnet.outputs.subnetResourceIds['aks']
      availabilityZones: [1, 2, 3]
    }
    additionalNodePools: [
      { name: 'apps', vmSize: 'Standard_D8s_v5', count: 3, enableAutoScaling: true, minCount: 3, maxCount: 10, subnetResourceId: vnet.outputs.subnetResourceIds['aks'] }
    ]
    adminGroupObjectIds: [platformAdminsGroupObjectId]
    monitoringWorkspaceResourceId: logs.outputs.resourceId
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): system pool, an autoscaling user pool, an admin group and Container Insights
