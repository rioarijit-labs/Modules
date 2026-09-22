# Private, Entra ID RBAC only cluster with a system pool, one user pool, workload identity and an admin group.
# Placeholder IDs: the test validates the module contract, it does not resolve these resources.
provider "azurerm" {
  features {}
}

module "test" {
  source = "../../"

  name              = "aks-defaults"
  location          = "westeurope"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"

  system_node_pool = {
    vm_size            = "Standard_D4s_v5"
    count              = 3
    subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-aks"
    availability_zones = ["1", "2", "3"]
  }

  additional_node_pools = {
    apps = {
      vm_size             = "Standard_D8s_v5"
      count               = 3
      enable_auto_scaling = true
      min_count           = 3
      max_count           = 10
      subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-aks"
    }
  }

  admin_group_object_ids           = ["00000000-0000-0000-0000-000000000001"]
  monitoring_workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.OperationalInsights/workspaces/log-example"
}
