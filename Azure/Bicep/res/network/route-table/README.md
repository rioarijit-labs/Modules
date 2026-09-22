# Route table

Route table with user-defined routes. Wraps `br/public:avm/res/network/route-table:0.5.0`.

## Notes

- Associate the table with a subnet through the `virtual-network` module's `routeTableResourceId` on that subnet.
- `disableBgpRoutePropagation: true` stops a VPN or ExpressRoute gateway's BGP-learned routes from overriding your route table — set it on any subnet where traffic must go through a firewall, so the gateway can't bypass it.
- `nextHopIpAddress` is required only when `nextHopType` is `VirtualAppliance` (pointing at a firewall or NVA's private IP).

## Usage

```bicep
module routeTable '../../res/network/route-table/main.bicep' = {
  name: 'route-table'
  params: {
    name: 'rt-spoke'
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'default-via-firewall'
        addressPrefix: '0.0.0.0/0'
        nextHopType: 'VirtualAppliance'
        nextHopIpAddress: firewall.outputs.privateIpAddress
      }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): default route through a firewall appliance
