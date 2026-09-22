# Virtual machine

Linux or Windows virtual machine. Wraps `br/public:avm/res/compute/virtual-machine:0.22.3`.

## Defaults

- **No public IP.** Reach the VM from inside the network, or through Azure Bastion, a VPN or ExpressRoute.
- **Authentication:** Linux uses an SSH key and password login is disabled. Windows uses a password you pass as a secure parameter (read it from Key Vault).
- **Microsoft Entra ID login** (`AADSSHLoginForLinux` or `AADLoginForWindows`) with a system-assigned managed identity. Grant `Virtual Machine Administrator Login` or `Virtual Machine User Login` through `roleAssignments`.
- **Trusted launch** (secure boot and vTPM) and **encryption at host**
- **Platform patching** (`AutomaticByPlatform`) and boot diagnostics on managed storage
- Zonal (zone 1), Premium SSD OS disk, accelerated networking, disks and NIC deleted with the VM
- Default images: Ubuntu 24.04 LTS, Windows Server 2025 Datacenter Azure Edition (both Generation 2)
- Default size `Standard_D2s_v5`

## Things that trip people up

- **Encryption at host** must be enabled on the subscription once: `az feature register --namespace Microsoft.Compute --name EncryptionAtHost`, then re-register the `Microsoft.Compute` provider. Otherwise deployment fails. Set `enableEncryptionAtHost` to false if you cannot.
- **Trusted launch needs a Generation 2 image.** If you supply a Generation 1 image, set `enableTrustedLaunch` to false.
- **Zones:** some regions have none. Set `availabilityZone` to `-1`.
- **Credentials:** pass `sshPublicKey` for Linux and `adminPassword` for Windows. The module does not create secrets. A missing one fails at deployment, not at compile time.
- **Windows computer names** are limited to 15 characters. The module truncates the VM name unless you set `computerName`.
- **Monitoring:** OS logs and metrics come from the Azure Monitor Agent. Pass `dataCollectionRuleResourceIds` and the agent is installed and associated. The rules themselves are not created by this module.
- **Reaching the VM:** without a public IP you need a path in. Azure Bastion is the usual one, and is not in this repo yet.

## Usage

```bicep
module vm '../../res/compute/virtual-machine/main.bicep' = {
  name: 'vm'
  params: {
    name: 'vm-app-001'
    osType: 'Linux'
    subnetResourceId: vnet.outputs.subnetResourceIds[0]
    sshPublicKey: sshPublicKey
    dataDisks: [
      { diskSizeGB: 256 }
    ]
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Virtual Machine Administrator Login'
        principalId: adminsGroupObjectId
        principalType: 'Group'
      }
    ]
  }
}
```

For Windows, set `osType: 'Windows'` and pass `adminPassword` from a secure parameter or a Key Vault reference.

## Tests

- [tests/linux](tests/linux/main.test.bicep): SSH key, data disk, Entra ID login role and auto-shutdown
- [tests/windows](tests/windows/main.test.bicep): generated password, Azure Monitor Agent and a data collection rule
