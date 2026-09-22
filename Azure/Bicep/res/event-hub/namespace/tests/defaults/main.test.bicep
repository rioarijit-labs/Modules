metadata name = 'Event Hubs namespace - defaults'
metadata description = 'Standard namespace with a telemetry event hub, two consumer groups and a data sender role.'

module test '../../main.bicep' = {
  name: 'test-event-hub-defaults'
  params: {
    name: 'evh-defaults-${take(uniqueString(resourceGroup().id), 8)}'
    eventHubs: [
      {
        name: 'telemetry'
        partitionCount: 4
        messageRetentionInDays: 3
        consumergroups: [
          { name: 'analytics' }
          { name: 'archive' }
        ]
      }
    ]
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Azure Event Hubs Data Sender'
        principalId: '00000000-0000-0000-0000-000000000001'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
