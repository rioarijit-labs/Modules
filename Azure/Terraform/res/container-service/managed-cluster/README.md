# AKS

Azure Kubernetes Service cluster. Wraps `Azure/avm-res-containerservice-managedcluster/azurerm` 0.8.3.

## Defaults

- **Private API server** (`enable_private_cluster = true`) — reachable only from inside the VNet, over VPN/ExpressRoute, or a jump host
- **Entra ID RBAC only** — `disableLocalAccounts` equivalent is on; no local Kubernetes admin accounts, cluster-admin is granted through `admin_group_object_ids` and Azure RBAC
- Azure CNI networking with Azure-native network policy
- Workload identity federation enabled, so pods can authenticate to Azure without stored secrets
- Key Vault Secrets Provider CSI driver enabled
- System-assigned managed identity for the control plane

## Node pools

`system_node_pool` is required — AKS needs at least one system pool for its own components. `additional_node_pools` adds user pools for application workloads, keyed by an arbitrary static name. Both take a `subnet_resource_id`, so pools can land in different subnets (Azure CNI requires routable VNet IPs per pod).

## Workload identity

Pair this module's `oidc_issuer_url` output with this repo's [managed-identity/user-assigned-identity](../../managed-identity/user-assigned-identity) module's `federated_identity_credentials`, using the pod's Kubernetes service account namespace/name as the subject. No client secret ever touches the cluster.

## Image pulls

Grant `kubelet_identity_object_id` (output) the `AcrPull` role on your [container-registry/registry](../../container-registry/registry) module via that module's `role_assignments`, so nodes can pull images without an `imagePullSecret`.

## Monitoring

Set `monitoring_workspace_resource_id` to a Log Analytics workspace resource ID to enable Container Insights. Left empty by default since not every cluster needs it wired up at creation.

## Usage

```hcl
module "aks" {
  source = "../../res/container-service/managed-cluster"

  name              = "aks-platform-001"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id

  system_node_pool = {
    vm_size            = "Standard_D4s_v5"
    count              = 3
    subnet_resource_id = module.network.subnet_resource_ids["aks"]
  }

  admin_group_object_ids = [var.aks_admins_group_object_id]
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): private cluster with a single system node pool
