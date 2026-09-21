# Ubuntu VM with an SSH key, a data disk, Entra ID login for an admin group and auto-shutdown.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name               = "vm-linux-test"
  location           = "westeurope"
  resource_group_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
  os_type            = "Linux"
  subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-workload"
  ssh_public_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleExampleExampleExampleExampleExample0000 test@example"

  data_disks = [
    { disk_size_gb = 128 },
  ]

  auto_shutdown_time = "1900"

  role_assignments = {
    admin_login = {
      role_definition_id_or_name = "Virtual Machine Administrator Login"
      principal_id               = "00000000-0000-0000-0000-000000000001"
      principal_type             = "Group"
    }
  }
}
