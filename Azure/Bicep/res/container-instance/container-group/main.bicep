metadata name = 'Container instance'
metadata description = 'A group of one or more containers scheduled directly on Azure Container Instances, with no orchestrator, placed inside your VNet (wraps AVM).'

@export()
@description('A container inside the group.')
type containerType = {
  @description('Name of the container.')
  name: string

  @description('Container image, e.g. "myregistry.azurecr.io/worker:1.0.0". Pin a tag or digest, not "latest".')
  image: string

  @description('CPU cores reserved for the container.')
  cpuCores: int

  @description('Memory in GB reserved for the container.')
  memoryInGB: int

  @description('Ports the container listens on.')
  ports: int[]?

  @description('Command to run instead of the image default, e.g. ["python", "worker.py"].')
  command: string[]?

  @description('Plain (non-secret) environment variables.')
  environmentVariables: object?

  @description('Secret environment variables, e.g. from Key Vault at deploy time. Never hard-code values here.')
  @secure()
  secureEnvironmentVariables: object?
}

@description('Name of the container group.')
param name string

@description('Azure region. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to the container group.')
param tags object = {}

@description('Containers to run in the group. They share the same network namespace and can reach each other over localhost.')
@minLength(1)
param containers containerType[]

@description('Operating system.')
@allowed([
  'Linux'
  'Windows'
])
param osType string = 'Linux'

@description('What Azure does if a container exits. Never for a long-running service that a failure should page on, OnFailure for retryable jobs.')
@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param restartPolicy string = 'Always'

@description('Subnet resource ID to place the container group in. Required for any private networking; container instances have no separate private endpoint concept, they live directly in the subnet.')
param subnetResourceId string

@description('Log Analytics workspace resource ID for container stdout/stderr logs. Leave empty to skip.')
param logAnalyticsWorkspaceResourceId string = ''

@description('Enable the system-assigned managed identity.')
param enableSystemAssignedIdentity bool = false

@description('Resource IDs of user-assigned managed identities to attach, e.g. one with AcrPull for a private registry.')
param userAssignedIdentityResourceIds string[] = []

@description('Availability zone: 1, 2 or 3. Use -1 for a regional group with no zone.')
@allowed([
  -1
  1
  2
  3
])
param availabilityZone int = -1

module containerGroup 'br/public:avm/res/container-instance/container-group:0.7.1' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    osType: osType
    restartPolicy: restartPolicy
    containers: map(containers, container => {
      name: container.name
      properties: {
        image: container.image
        resources: {
          requests: {
            cpu: container.cpuCores
            memoryInGB: string(container.memoryInGB)
          }
        }
        ports: map(container.?ports ?? [], port => {
          port: port
          protocol: 'TCP'
        })
        command: container.?command
        environmentVariables: concat(
          map(items(container.?environmentVariables ?? {}), item => {
            name: item.key
            value: item.value
          }),
          map(items(container.?secureEnvironmentVariables ?? {}), item => {
            name: item.key
            secureValue: item.value
          })
        )
      }
    })
    // No public IP: the group lives only in the subnet
    ipAddress: {
      type: 'Private'
      ports: map(containers, container => {
        port: first(container.?ports ?? [80])
        protocol: 'TCP'
      })
    }
    subnets: [
      {
        subnetResourceId: subnetResourceId
      }
    ]
    availabilityZone: availabilityZone
    logAnalytics: empty(logAnalyticsWorkspaceResourceId)
      ? null
      : {
          logType: 'ContainerInsights'
          workspaceResourceId: logAnalyticsWorkspaceResourceId
        }
    managedIdentities: {
      systemAssigned: enableSystemAssignedIdentity
      userAssignedResourceIds: userAssignedIdentityResourceIds
    }
  }
}

@description('Resource ID of the container group.')
output resourceId string = containerGroup.outputs.resourceId

@description('Name of the container group.')
output name string = containerGroup.outputs.name

@description('Private IPv4 address of the group inside the subnet.')
output ipAddress string = containerGroup.outputs.?iPv4Address ?? ''

@description('Principal ID of the system-assigned identity. Empty when not enabled.')
output systemAssignedMIPrincipalId string = containerGroup.outputs.?systemAssignedMIPrincipalId ?? ''
