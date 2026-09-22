metadata name = 'AKS'
metadata description = 'Azure Kubernetes Service cluster: private API server, Entra ID RBAC only, workload identity and the Key Vault Secrets Provider on by default (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@export()
@description('A node pool.')
type nodePoolType = {
  @description('Name of the node pool. 1-12 characters, lowercase letters and numbers.')
  name: string

  @description('VM size, e.g. "Standard_D4s_v5".')
  vmSize: string

  @description('Fixed node count. Ignored when enableAutoScaling is true; set minCount/maxCount instead.')
  count: int

  @description('Enable the cluster autoscaler for this pool.')
  enableAutoScaling: bool?

  @description('Minimum nodes when autoscaling.')
  minCount: int?

  @description('Maximum nodes when autoscaling.')
  maxCount: int?

  @description('Subnet resource ID the pool nodes (and Azure CNI pods) are placed in.')
  subnetResourceId: string

  @description('Availability zones for the pool, e.g. [1, 2, 3]. Leave empty for no zone pinning.')
  availabilityZones: int[]?
}

@description('Name of the cluster.')
@minLength(1)
@maxLength(63)
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to the cluster.')
param tags object = {}

@description('DNS prefix for the cluster, part of the API server\'s FQDN. Defaults to the cluster name.')
param dnsPrefix string = name

@description('Kubernetes version, e.g. "1.30". Leave empty to use AKS\'s current default.')
param kubernetesVersion string = ''

@description('Free has no SLA. Standard and Premium add an uptime SLA; Premium adds long-term support windows.')
@allowed([
  'Free'
  'Standard'
  'Premium'
])
param skuTier string = 'Standard'

@description('The initial system node pool. AKS requires at least one system pool for its own components.')
param systemNodePool nodePoolType

@description('Additional user node pools for application workloads.')
param additionalNodePools nodePoolType[] = []

@description('Azure CNI gives pods routable VNet IPs (needed for private endpoint access from pods, and for network policy). Kubenet is simpler but more limited and being phased out for new clusters.')
@allowed([
  'azure'
  'kubenet'
])
param networkPlugin string = 'azure'

@description('Enforce Kubernetes NetworkPolicy (pod-to-pod traffic rules) using Azure\'s own implementation.')
param networkPolicy string = 'azure'

@description('No public API server endpoint; reach it from inside the VNet, over VPN/ExpressRoute, or through a jump host. Set to false only for a lab where that\'s inconvenient.')
param enablePrivateCluster bool = true

@description('Microsoft Entra ID object IDs (users or groups) granted cluster-admin Kubernetes RBAC.')
param adminGroupObjectIds string[] = []

@description('Enable workload identity federation, so pods authenticate to Azure with a federated Entra ID credential instead of a stored secret. Pair with the managed-identity module\'s federatedIdentityCredentials, using this cluster\'s oidcIssuerUrl output as the issuer.')
param enableWorkloadIdentity bool = true

@description('Enable the Key Vault Secrets Provider CSI driver, so pods can mount Key Vault secrets as files without an SDK.')
param enableKeyVaultSecretsProvider bool = true

@description('Log Analytics workspace resource ID for Container Insights. Leave empty to skip.')
param monitoringWorkspaceResourceId string = ''

@description('Enable the system-assigned managed identity for the cluster\'s own control plane.')
param enableSystemAssignedIdentity bool = true

@description('Resource IDs of user-assigned managed identities to attach to the cluster control plane.')
param userAssignedIdentityResourceIds string[] = []

@description('Azure RBAC role assignments on the cluster resource, e.g. "Azure Kubernetes Service RBAC Cluster Admin" for an admin group, or "Azure Kubernetes Service Cluster User Role" to allow fetching kubeconfig.')
param roleAssignments roleAssignmentType[] = []

var systemPoolConfig = {
  name: systemNodePool.name
  vmSize: systemNodePool.vmSize
  mode: 'System'
  count: systemNodePool.count
  enableAutoScaling: systemNodePool.?enableAutoScaling ?? false
  minCount: systemNodePool.?minCount
  maxCount: systemNodePool.?maxCount
  vnetSubnetResourceId: systemNodePool.subnetResourceId
  availabilityZones: systemNodePool.?availabilityZones
  osType: 'Linux'
}

var userPoolsConfig = [
  for pool in additionalNodePools: {
    name: pool.name
    vmSize: pool.vmSize
    mode: 'User'
    count: pool.count
    enableAutoScaling: pool.?enableAutoScaling ?? false
    minCount: pool.?minCount
    maxCount: pool.?maxCount
    vnetSubnetResourceId: pool.subnetResourceId
    availabilityZones: pool.?availabilityZones
    osType: 'Linux'
  }
]

module managedCluster 'br/public:avm/res/container-service/managed-cluster:0.14.0' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    dnsPrefix: dnsPrefix
    kubernetesVersion: empty(kubernetesVersion) ? null : kubernetesVersion
    skuTier: skuTier
    primaryAgentPoolProfiles: [systemPoolConfig]
    agentPools: userPoolsConfig
    networkPlugin: networkPlugin
    networkPolicy: networkPolicy
    // Secure defaults: Entra ID RBAC only, private API server, workload identity
    disableLocalAccounts: true
    aadProfile: {
      managed: true
      enableAzureRBAC: true
      adminGroupObjectIDs: adminGroupObjectIds
    }
    apiServerAccessProfile: {
      enablePrivateCluster: enablePrivateCluster
    }
    enableOidcIssuerProfile: enableWorkloadIdentity
    securityProfile: {
      workloadIdentity: {
        enabled: enableWorkloadIdentity
      }
    }
    enableKeyvaultSecretsProvider: enableKeyVaultSecretsProvider
    enableSecretRotation: enableKeyVaultSecretsProvider
    omsAgentEnabled: !empty(monitoringWorkspaceResourceId)
    monitoringWorkspaceResourceId: empty(monitoringWorkspaceResourceId) ? null : monitoringWorkspaceResourceId
    managedIdentities: {
      systemAssigned: enableSystemAssignedIdentity
      userAssignedResourceIds: userAssignedIdentityResourceIds
    }
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the cluster.')
output resourceId string = managedCluster.outputs.resourceId

@description('Name of the cluster.')
output name string = managedCluster.outputs.name

@description('Control plane FQDN. Only reachable from inside the network when enablePrivateCluster is true.')
output controlPlaneFqdn string = managedCluster.outputs.controlPlaneFQDN

@description('OIDC issuer URL. Use this as the issuer in the managed-identity module\'s federatedIdentityCredentials for workload identity.')
output oidcIssuerUrl string = managedCluster.outputs.?oidcIssuerUrl ?? ''

@description('Principal ID of the cluster\'s system-assigned identity. Empty when not enabled.')
output systemAssignedMIPrincipalId string = managedCluster.outputs.?systemAssignedMIPrincipalId ?? ''

@description('Principal (object) ID of the kubelet identity, used by nodes to pull images and manage load balancer/disk resources. Grant it AcrPull on your registry.')
output kubeletIdentityObjectId string = managedCluster.outputs.?kubeletIdentityObjectId ?? ''
