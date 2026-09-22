# Virtual WAN hub

A Virtual WAN and one hub inside it, with spoke connections. Composes `br/public:avm/res/network/virtual-wan:0.4.3` and `br/public:avm/res/network/virtual-hub:0.5.1` in one module, since a hub with no WAN (or a WAN with no hub) deploys nothing useful.

## Virtual WAN hub vs a hand-built hub

This repo also has [virtual-network](../virtual-network), which you can use as a hand-built hub with peerings to spokes. Virtual WAN is Microsoft's managed alternative: it handles hub routing, scales to many hubs and regions, and is the standard choice once you have branch/VPN/ExpressRoute connectivity or more spokes than a peering mesh handles comfortably. For a single-region setup with a handful of spokes, a hand-built hub VNet is simpler and cheaper.

## No Terraform equivalent

There is no published AVM Terraform module for either `virtual-wan` or `virtual-hub` at the time this was written, so this module exists only for Bicep. See the [Terraform README](../../../../../docs/terraform/README.md#differences-from-the-bicep-modules) for how gaps like this are tracked.

## Connecting Azure Firewall

Deploy [azure-firewall](../azure-firewall) with `virtualHubResourceId` set to this module's `hubResourceId` output for a Secure Virtual Hub, instead of the standalone-VNet firewall deployment that module's own example shows.

## Usage

```bicep
module hub '../../res/network/virtual-wan-hub/main.bicep' = {
  name: 'hub'
  params: {
    name: 'vwan-platform'
    hubName: 'hub-westeurope'
    hubAddressPrefix: '10.0.0.0/24'
    spokeConnections: [
      { name: 'spoke-workload', remoteVirtualNetworkResourceId: spokeVnet.outputs.resourceId }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): Standard WAN and hub with one spoke connection
