metadata name = 'Firewall policy - defaults'
metadata description = 'One rule collection group with a network rule and an application rule.'

module test '../../main.bicep' = {
  name: 'test-firewall-policy-defaults'
  params: {
    name: 'fwpolicy-defaults'
    ruleCollectionGroups: [
      {
        name: 'spoke-egress'
        priority: 200
        networkRules: [
          {
            name: 'allow-dns'
            ipProtocols: ['UDP']
            sourceAddresses: ['10.0.0.0/16']
            destinationAddresses: ['*']
            destinationPorts: ['53']
          }
        ]
        applicationRules: [
          {
            name: 'allow-updates'
            sourceAddresses: ['10.0.0.0/16']
            targetFqdns: ['*.microsoft.com', '*.windowsupdate.com']
            protocols: [
              { protocolType: 'Https', port: 443 }
            ]
          }
        ]
      }
    ]
  }
}
