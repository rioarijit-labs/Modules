metadata name = 'Cosmos DB account'
metadata description = 'Secure-by-default Cosmos DB account (SQL/Core API) with databases, containers and native data-plane RBAC, private by default (wraps AVM).'

import { roleAssignmentType } from '../../../utl/types/main.bicep'

@export()
@description('A container inside a SQL database.')
type containerType = {
  @description('Name of the container.')
  name: string

  @description('Partition key paths, e.g. ["/id"] or a hierarchical key ["/tenantId", "/userId"].')
  @minLength(1)
  partitionKeyPaths: string[]

  @description('Dedicated request units per second for this container. Omit to share the database-level throughput.')
  throughput: int?

  @description('Default time-to-live for items, in seconds. Omit to disable expiry. Use -1 to allow items to opt in individually with no default expiry.')
  ttlSeconds: int?
}

@export()
@description('A SQL (Core) API database and its containers.')
type sqlDatabaseType = {
  @description('Name of the database.')
  name: string

  @description('Containers in the database.')
  containers: containerType[]

  @description('Shared request units per second across all containers in the database. Omit to set throughput per container, or when using serverless capacity.')
  throughput: int?
}

@export()
@description('A data-plane role assignment using Cosmos DB\'s built-in SQL RBAC. Distinct from roleAssignments: Azure RBAC only covers management operations, and with disableLocalAuthentication on, applications need one of these to read or write data.')
type dataRoleAssignmentType = {
  @description('Object ID of the principal (e.g. an app\'s managed identity).')
  principalId: string

  @description('Reader can query and read items. Contributor can also create, update and delete.')
  role: 'Reader' | 'Contributor'
}

@description('Name of the Cosmos DB account. 3-44 characters, lowercase letters, numbers and hyphens. Globally unique.')
@minLength(3)
@maxLength(44)
param name string

@description('Azure region for the primary (write) location. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Tags applied to all resources.')
param tags object = {}

@description('Additional read regions, as region names, e.g. ["westus2"]. Requires zoneRedundant and enableAutomaticFailover to matter; leave empty for a single-region account.')
param additionalLocations string[] = []

@description('Spread each region across availability zones. Not available in every region.')
param zoneRedundant bool = false

@description('Promote a read region to primary automatically if the write region fails. Needs at least one entry in additionalLocations.')
param enableAutomaticFailover bool = false

@description('Consistency guarantee for reads. Session is the right default for most apps; Strong costs the most latency and RU.')
@allowed([
  'Eventual'
  'ConsistentPrefix'
  'Session'
  'BoundedStaleness'
  'Strong'
])
param defaultConsistencyLevel string = 'Session'

@description('Provisioned: pay for reserved RU/s. Serverless: pay per request, cheaper for spiky or low-traffic workloads, but capped at 5000 RU/s and cannot use free tier.')
@allowed([
  'Provisioned'
  'Serverless'
])
param capacityMode string = 'Provisioned'

@description('Apply the subscription\'s one free tier (1000 RU/s and 25 GB) to this account. Only one account per subscription can use it, and it fails deployment if another already has it.')
param enableFreeTier bool = false

@description('SQL databases and containers to create.')
param sqlDatabases sqlDatabaseType[] = []

@description('Continuous enables point-in-time restore. Periodic takes scheduled snapshots and is cheaper for large, rarely-restored accounts.')
@allowed([
  'Continuous'
  'Periodic'
])
param backupPolicyType string = 'Continuous'

@description('Public network access. Disabled by default: reach the account through a private endpoint.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Subnet resource ID for the private endpoint. Leave empty to skip the private endpoint.')
param privateEndpointSubnetResourceId string = ''

@description('Private DNS zone resource IDs for the endpoint, e.g. privatelink.documents.azure.com.')
param privateDnsZoneResourceIds string[] = []

@description('Log Analytics workspace resource ID for diagnostic settings. Leave empty to skip diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('Enable the system-assigned managed identity.')
param enableSystemAssignedIdentity bool = false

@description('Resource IDs of user-assigned managed identities to attach.')
param userAssignedIdentityResourceIds string[] = []

@description('Azure RBAC role assignments on the account resource (management plane only, e.g. "Cosmos DB Account Reader Role"). This does not grant data access: use dataRoleAssignments for that.')
param roleAssignments roleAssignmentType[] = []

@description('Data-plane role assignments through Cosmos DB\'s own RBAC. Required for any application to read or write data, since disableLocalAuthentication is always on.')
param dataRoleAssignments dataRoleAssignmentType[] = []

var cosmosBuiltInDataRoleIds = {
  Reader: '00000000-0000-0000-0000-000000000001'
  Contributor: '00000000-0000-0000-0000-000000000002'
}

var primaryFailoverLocation = {
  locationName: location
  failoverPriority: 0
  isZoneRedundant: zoneRedundant
}
var additionalFailoverLocations = [
  for (additionalLocation, i) in additionalLocations: {
    locationName: additionalLocation
    failoverPriority: i + 1
    isZoneRedundant: zoneRedundant
  }
]

var sqlDatabasesConfig = [
  for database in sqlDatabases: {
    name: database.name
    throughput: database.?throughput
    containers: map(database.containers, container => {
      name: container.name
      paths: container.partitionKeyPaths
      throughput: container.?throughput
      defaultTtl: container.?ttlSeconds
    })
  }
]

var dnsZoneGroupConfigs = [
  for zoneResourceId in privateDnsZoneResourceIds: {
    privateDnsZoneResourceId: zoneResourceId
  }
]

module cosmosDbAccount 'br/public:avm/res/document-db/database-account:0.21.1' = {
  name: '${take(name, 40)}-avm'
  params: {
    name: name
    location: location
    tags: tags
    failoverLocations: concat([primaryFailoverLocation], additionalFailoverLocations)
    enableAutomaticFailover: enableAutomaticFailover
    defaultConsistencyLevel: defaultConsistencyLevel
    capacityMode: capacityMode
    enableFreeTier: enableFreeTier
    backupPolicyType: backupPolicyType
    sqlDatabases: sqlDatabasesConfig
    // Secure defaults: Entra ID only, private access
    disableLocalAuthentication: true
    networkRestrictions: {
      publicNetworkAccess: publicNetworkAccess
      networkAclBypass: 'AzureServices'
    }
    privateEndpoints: empty(privateEndpointSubnetResourceId)
      ? []
      : [
          {
            service: 'Sql'
            subnetResourceId: privateEndpointSubnetResourceId
            tags: tags
            privateDnsZoneGroup: empty(dnsZoneGroupConfigs)
              ? null
              : {
                  privateDnsZoneGroupConfigs: dnsZoneGroupConfigs
                }
          }
        ]
    diagnosticSettings: empty(diagnosticsWorkspaceResourceId)
      ? []
      : [
          { workspaceResourceId: diagnosticsWorkspaceResourceId }
        ]
    managedIdentities: {
      systemAssigned: enableSystemAssignedIdentity
      userAssignedResourceIds: userAssignedIdentityResourceIds
    }
    roleAssignments: roleAssignments
    sqlRoleAssignments: [
      for dataRoleAssignment in dataRoleAssignments: {
        principalId: dataRoleAssignment.principalId
        roleDefinitionId: '${resourceId('Microsoft.DocumentDB/databaseAccounts', name)}/sqlRoleDefinitions/${cosmosBuiltInDataRoleIds[dataRoleAssignment.role]}'
      }
    ]
  }
}

@description('Resource ID of the Cosmos DB account.')
output resourceId string = cosmosDbAccount.outputs.resourceId

@description('Name of the Cosmos DB account.')
output name string = cosmosDbAccount.outputs.name

@description('SQL (Core) API endpoint URL.')
output endpoint string = cosmosDbAccount.outputs.endpoint

@description('Principal ID of the system-assigned identity. Empty when not enabled.')
output systemAssignedMIPrincipalId string = cosmosDbAccount.outputs.?systemAssignedMIPrincipalId ?? ''
