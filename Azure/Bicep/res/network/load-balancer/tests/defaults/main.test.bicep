metadata name = 'Load balancer - defaults'
metadata description = 'Standard internal load balancer with a health probe and one balancing rule.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-load-balancer-defaults'
  params: {
    name: 'lb-defaults'
    subnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-workload'
    backendPoolNames: ['web-instances']
    probes: [
      {
        name: 'http-health'
        protocol: 'Http'
        port: 80
        requestPath: '/healthz'
      }
    ]
    loadBalancingRules: [
      {
        name: 'http'
        protocol: 'Tcp'
        frontendPort: 80
        backendPort: 80
        backendPoolName: 'web-instances'
        probeName: 'http-health'
      }
    ]
  }
}
