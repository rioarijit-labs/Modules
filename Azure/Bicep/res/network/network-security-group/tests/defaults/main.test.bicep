metadata name = 'Network security group - defaults'
metadata description = 'HTTPS-only inbound from the internet plus the default explicit deny-all.'

module test '../../main.bicep' = {
  name: 'test-nsg-defaults'
  params: {
    name: 'nsg-defaults'
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '443'
        }
      }
    ]
  }
}
