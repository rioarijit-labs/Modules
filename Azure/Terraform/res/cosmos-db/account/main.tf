locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  cosmos_built_in_data_role_ids = {
    Reader      = "00000000-0000-0000-0000-000000000001"
    Contributor = "00000000-0000-0000-0000-000000000002"
  }

  primary_geo_location = {
    location          = var.location
    failover_priority = 0
    zone_redundant    = var.zone_redundant
  }
  additional_geo_locations = [
    for index, additional_location in var.additional_locations : {
      location          = additional_location
      failover_priority = index + 1
      zone_redundant    = var.zone_redundant
    }
  ]

  sql_databases = {
    for database_name, database in var.sql_databases : database_name => {
      name       = database_name
      throughput = var.serverless ? null : database.throughput
      containers = {
        for container_name, container in database.containers : container_name => {
          name                = container_name
          partition_key_paths = container.partition_key_paths
          throughput          = var.serverless ? null : container.throughput
          default_ttl         = container.default_ttl_seconds
        }
      }
    }
  }

  private_endpoints = var.private_endpoint == null ? {} : {
    account = {
      subnet_resource_id            = var.private_endpoint.subnet_resource_id
      subresource_name              = "Sql"
      private_dns_zone_resource_ids = toset(var.private_endpoint.private_dns_zone_resource_ids)
      tags                          = var.tags
    }
  }

  diagnostic_settings = var.diagnostics == null ? {} : {
    default = {
      workspace_resource_id = var.diagnostics.workspace_resource_id
    }
  }
}

module "cosmos_db_account" {
  source  = "Azure/avm-res-documentdb-databaseaccount/azurerm"
  version = "0.11.0"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags

  geo_locations              = concat([local.primary_geo_location], local.additional_geo_locations)
  automatic_failover_enabled = var.enable_automatic_failover
  consistency_policy = {
    consistency_level = var.consistency_level
  }
  capabilities      = var.serverless ? [{ name = "EnableServerless" }] : []
  free_tier_enabled = var.free_tier_enabled
  backup            = { type = var.backup_policy_type }
  sql_databases     = local.sql_databases

  # Secure defaults: Entra ID only, private access
  local_authentication_disabled         = true
  public_network_access_enabled         = var.public_network_access_enabled
  network_acl_bypass_for_azure_services = true

  private_endpoints   = local.private_endpoints
  diagnostic_settings = local.diagnostic_settings
  managed_identities = {
    system_assigned            = var.enable_system_assigned_identity
    user_assigned_resource_ids = var.user_assigned_identity_resource_ids
  }
  role_assignments = var.role_assignments
}

# The upstream AVM module does not yet create Cosmos DB's own SQL role assignments, so this
# module creates them directly. Without one of these, local_authentication_disabled means no
# application can read or write data, even with an Azure RBAC role from var.role_assignments.
resource "azurerm_cosmosdb_sql_role_assignment" "data" {
  for_each = var.data_role_assignments

  name                = uuidv5("dns", "${module.cosmos_db_account.resource_id}/${each.key}")
  resource_group_name = local.resource_group_name
  account_name        = module.cosmos_db_account.name
  role_definition_id  = "${module.cosmos_db_account.resource_id}/sqlRoleDefinitions/${local.cosmos_built_in_data_role_ids[each.value.role]}"
  principal_id        = each.value.principal_id
  scope               = module.cosmos_db_account.resource_id
}
