metadata name = 'Cosmos DB account - defaults'
metadata description = 'Single-region account with one SQL database, a shared-throughput container and a data reader role for an app identity.'

module test '../../main.bicep' = {
  name: 'test-cosmos-db-account-defaults'
  params: {
    name: 'cosmos-defaults-${take(uniqueString(resourceGroup().id), 8)}'
    sqlDatabases: [
      {
        name: 'catalog'
        throughput: 400
        containers: [
          {
            name: 'products'
            partitionKeyPaths: ['/category']
            ttlSeconds: -1
          }
        ]
      }
    ]
    dataRoleAssignments: [
      {
        principalId: '00000000-0000-0000-0000-000000000001'
        role: 'Reader'
      }
    ]
  }
}
