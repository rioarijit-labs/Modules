metadata name = 'Container app'
metadata description = 'Single-container Container App with managed identity registry pull, Key Vault secrets and internal ingress by default (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@export()
@description('An environment variable for the container.')
type envVarType = {
  @description('Name of the variable.')
  name: string

  @description('Plain value. Set either value or secretRef, not both.')
  value: string?

  @description('Name of an entry in the secrets parameter to read the value from.')
  secretRef: string?
}

@export()
@description('A secret read from Key Vault at runtime through a managed identity.')
type keyVaultSecretType = {
  @description('Name the secret is known by inside the app. Lowercase letters, numbers and hyphens.')
  name: string

  @description('Secret URI in Key Vault, e.g. https://<vault>.vault.azure.net/secrets/<name>. Omit the version to always use the latest.')
  keyVaultUrl: string

  @description('Resource ID of the user-assigned identity used to read the secret. It needs the "Key Vault Secrets User" role. Use "system" for the system-assigned identity.')
  identity: string
}

@description('Name of the container app. 2-32 characters, lowercase letters, numbers and hyphens, starting with a letter.')
@minLength(2)
@maxLength(32)
param name string

@description('Azure region. Defaults to the resource group location. Must match the environment.')
param location string = resourceGroup().location

@description('Tags applied to the app.')
param tags object = {}

@description('Resource ID of the Container Apps environment to run in.')
param environmentResourceId string

@description('Container image, e.g. "myregistry.azurecr.io/api:1.4.2". Pin a tag or digest, not "latest".')
param image string

@description('Name of the container inside the app.')
param containerName string = 'main'

@description('CPU cores for the container, e.g. "0.25", "0.5", "1". Must pair with a valid memory value.')
param cpu string = '0.5'

@description('Memory for the container, e.g. "1Gi". Must pair with a valid CPU value (memory is CPU x 2 on the Consumption profile).')
param memory string = '1Gi'

@description('Environment variables for the container.')
param env envVarType[] = []

@description('Secrets read from Key Vault. Reference them from env with secretRef.')
param secrets keyVaultSecretType[] = []

@description('Port the container listens on. Ingress forwards to it.')
@minValue(1)
@maxValue(65535)
param targetPort int = 8080

@description('Expose the app to the internet through the environment public endpoint. Off by default: the app is reachable only inside the environment.')
param ingressExternal bool = false

@description('Turn ingress off entirely, for background workers with no HTTP endpoint.')
param disableIngress bool = false

@description('Minimum replicas. 0 scales to zero and adds cold-start latency.')
@minValue(0)
@maxValue(1000)
param minReplicas int = 1

@description('Maximum replicas.')
@minValue(1)
@maxValue(1000)
param maxReplicas int = 3

@description('Registry login server to pull from, e.g. "myregistry.azurecr.io". Leave empty for public images.')
param registryServer string = ''

@description('Resource ID of a user-assigned managed identity with the "AcrPull" role on the registry. Required when registryServer is set. A user-assigned identity is used because it exists before the app does, so the first revision can pull.')
param registryIdentityResourceId string = ''

@description('Resource IDs of additional user-assigned managed identities to attach.')
param userAssignedIdentityResourceIds string[] = []

@description('Enable the system-assigned managed identity.')
param enableSystemAssignedIdentity bool = true

@description('RBAC role assignments on the app.')
param roleAssignments roleAssignmentType[] = []

var identityResourceIds = union(
  userAssignedIdentityResourceIds,
  empty(registryIdentityResourceId) ? [] : [registryIdentityResourceId]
)

module containerApp 'br/public:avm/res/app/container-app:0.23.0' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    environmentResourceId: environmentResourceId
    workloadProfileName: 'Consumption'
    containers: [
      {
        name: containerName
        image: image
        resources: {
          cpu: json(cpu)
          memory: memory
        }
        env: env
      }
    ]
    scaleSettings: {
      minReplicas: minReplicas
      maxReplicas: maxReplicas
    }
    // Ingress: internal HTTPS only by default
    disableIngress: disableIngress
    ingressExternal: ingressExternal
    ingressTargetPort: targetPort
    ingressAllowInsecure: false
    secrets: [
      for secret in secrets: {
        name: secret.name
        keyVaultUrl: secret.keyVaultUrl
        identity: secret.identity
      }
    ]
    registries: empty(registryServer)
      ? []
      : [
          {
            server: registryServer
            identity: registryIdentityResourceId
          }
        ]
    managedIdentities: {
      systemAssigned: enableSystemAssignedIdentity
      userAssignedResourceIds: identityResourceIds
    }
    roleAssignments: roleAssignments
  }
}

@description('Resource ID of the container app.')
output resourceId string = containerApp.outputs.resourceId

@description('Name of the container app.')
output name string = containerApp.outputs.name

@description('Fully qualified domain name of the app. Empty when ingress is disabled.')
output fqdn string = containerApp.outputs.fqdn

@description('Principal ID of the system-assigned identity. Empty when not enabled.')
output systemAssignedMIPrincipalId string = containerApp.outputs.?systemAssignedMIPrincipalId ?? ''
