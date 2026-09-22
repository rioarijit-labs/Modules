locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  default_agent_pool = {
    vm_size             = var.system_node_pool.vm_size
    count_of            = var.system_node_pool.count
    enable_auto_scaling = var.system_node_pool.enable_auto_scaling
    min_count           = var.system_node_pool.min_count
    max_count           = var.system_node_pool.max_count
    vnet_subnet_id      = var.system_node_pool.subnet_resource_id
    availability_zones  = var.system_node_pool.availability_zones
    os_type             = "Linux"
  }

  agent_pools = {
    for pool_name, pool in var.additional_node_pools : pool_name => {
      vm_size             = pool.vm_size
      count_of            = pool.count
      enable_auto_scaling = pool.enable_auto_scaling
      min_count           = pool.min_count
      max_count           = pool.max_count
      vnet_subnet_id      = pool.subnet_resource_id
      availability_zones  = pool.availability_zones
      os_type             = "Linux"
    }
  }
}

module "managed_cluster" {
  source  = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version = "0.8.3"

  name               = var.name
  location           = var.location
  parent_id          = var.resource_group_id
  tags               = var.tags
  dns_prefix         = coalesce(var.dns_prefix, var.name)
  kubernetes_version = var.kubernetes_version

  sku = {
    tier = var.sku_tier
  }

  default_agent_pool = local.default_agent_pool
  agent_pools        = local.agent_pools

  network_profile = {
    network_plugin = var.network_plugin
    network_policy = var.network_policy
  }

  # Secure defaults: Entra ID RBAC only, private API server, workload identity
  disable_local_accounts = true
  aad_profile = {
    managed                = true
    enable_azure_rbac      = true
    admin_group_object_ids = var.admin_group_object_ids
  }
  api_server_access_profile = {
    enable_private_cluster = var.enable_private_cluster
  }
  oidc_issuer_profile = {
    enabled = var.enable_workload_identity
  }
  security_profile = {
    workload_identity = {
      enabled = var.enable_workload_identity
    }
    image_cleaner = {
      enabled = var.enable_key_vault_secrets_provider
    }
  }

  addon_profile_oms_agent = var.monitoring_workspace_resource_id == "" ? null : {
    enabled = true
    config = {
      log_analytics_workspace_resource_id = var.monitoring_workspace_resource_id
    }
  }

  managed_identities = {
    system_assigned            = var.enable_system_assigned_identity
    user_assigned_resource_ids = var.user_assigned_identity_resource_ids
  }
  role_assignments = var.role_assignments
}
