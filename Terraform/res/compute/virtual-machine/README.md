# Virtual machine

Linux or Windows virtual machine. Wraps `Azure/avm-res-compute-virtualmachine/azurerm` 0.21.0.

## Defaults

- **No public IP.** Reach the VM from inside the network, or through Azure Bastion, a VPN or ExpressRoute.
- **Authentication:** Linux uses an SSH key and password login is disabled. Windows uses a password you pass as a sensitive variable (read it from Key Vault). Nothing is generated for you, so no credential ends up in state by accident.
- **Microsoft Entra ID login** (`AADSSHLoginForLinux` or `AADLoginForWindows`) with a system-assigned managed identity. Grant `Virtual Machine Administrator Login` or `Virtual Machine User Login` through `role_assignments`.
- **Trusted launch** (secure boot and vTPM) and **encryption at host**
- **Platform patching** (`AutomaticByPlatform`) and boot diagnostics on managed storage
- Zonal (zone 1), Premium SSD OS disk, accelerated networking
- Default images: Ubuntu 24.04 LTS, Windows Server 2025 Datacenter Azure Edition (both Generation 2)
- Default size `Standard_D2s_v5`

## Things that trip people up

- **Encryption at host** must be enabled on the subscription once: `az feature register --namespace Microsoft.Compute --name EncryptionAtHost`, then re-register the `Microsoft.Compute` provider. Otherwise deployment fails. Set `enable_encryption_at_host` to false if you cannot.
- **Trusted launch needs a Generation 2 image.** If you supply a Generation 1 image, set `enable_trusted_launch` to false.
- **Zones:** some regions have none. Set `availability_zone` to `null`.
- **Credentials:** pass `ssh_public_key` for Linux and `admin_password` for Windows. A missing one fails at deployment, not at validation.
- **Windows computer names** are limited to 15 characters. The module truncates the VM name unless you set `computer_name`.
- **Monitoring:** OS logs and metrics come from the Azure Monitor Agent. Pass `data_collection_rule_resource_ids` and the agent is installed and associated. The rules themselves are not created by this module.
- **Reaching the VM:** without a public IP you need a path in. Azure Bastion is the usual one, and is not in this repo yet.
- `terraform validate` on this module prints a deprecation warning from inside the upstream AVM module. It is harmless.

## Usage

```hcl
module "vm" {
  source = "../../res/compute/virtual-machine"

  name               = "vm-app-001"
  location           = "westeurope"
  resource_group_id  = azurerm_resource_group.this.id
  os_type            = "Linux"
  subnet_resource_id = module.network.subnet_resource_ids["workload"]
  ssh_public_key     = file("~/.ssh/id_ed25519.pub")

  data_disks = [
    { disk_size_gb = 256 },
  ]

  role_assignments = {
    admin_login = {
      role_definition_id_or_name = "Virtual Machine Administrator Login"
      principal_id               = var.admins_group_object_id
      principal_type             = "Group"
    }
  }
}
```

For Windows, set `os_type = "Windows"` and pass `admin_password` from a sensitive variable or a Key Vault data source.

## Tests

- [tests/linux](tests/linux/main.tf): SSH key, data disk, Entra ID login role and auto-shutdown
- [tests/windows](tests/windows/main.tf): generated password, Azure Monitor Agent and a data collection rule
