metadata name = 'Route table - defaults'
metadata description = 'Default route through a firewall appliance, with BGP propagation disabled.'

module test '../../main.bicep' = {
  name: 'test-route-table-defaults'
  params: {
    name: 'rt-defaults'
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'default-via-firewall'
        addressPrefix: '0.0.0.0/0'
        nextHopType: 'VirtualAppliance'
        nextHopIpAddress: '10.0.0.4'
      }
    ]
  }
}
