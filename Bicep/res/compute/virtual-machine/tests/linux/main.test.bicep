metadata name = 'Virtual machine - Linux'
metadata description = 'Ubuntu VM with an SSH key, a data disk, Entra ID login for an admin group and auto-shutdown.'

// Placeholder IDs: the test validates the module contract, it does not resolve these resources.
module test '../../main.bicep' = {
  name: 'test-virtual-machine-linux'
  params: {
    name: 'vm-linux-test'
    osType: 'Linux'
    subnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-workload'
    sshPublicKey: 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleExampleExampleExampleExampleExample0000 test@example'
    dataDisks: [
      { diskSizeGB: 128 }
    ]
    autoShutdownTime: '1900'
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Virtual Machine Administrator Login'
        principalId: '00000000-0000-0000-0000-000000000001'
        principalType: 'Group'
      }
    ]
  }
}
