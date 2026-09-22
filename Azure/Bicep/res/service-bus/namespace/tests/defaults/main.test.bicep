metadata name = 'Service Bus namespace - defaults'
metadata description = 'Premium namespace with an orders queue and an events topic with two subscriptions.'

module test '../../main.bicep' = {
  name: 'test-service-bus-defaults'
  params: {
    name: 'sb-defaults-${take(uniqueString(resourceGroup().id), 8)}'
    queues: [
      {
        name: 'orders'
        maxDeliveryCount: 5
        lockDuration: 'PT1M'
        deadLetteringOnMessageExpiration: true
      }
    ]
    topics: [
      {
        name: 'events'
        subscriptions: [
          { name: 'billing', maxDeliveryCount: 10 }
          { name: 'notifications' }
        ]
      }
    ]
  }
}
