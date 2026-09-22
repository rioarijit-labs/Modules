# SQL Server

Azure SQL logical server with one or more single databases. Wraps `Azure/avm-res-sql-server/azurerm` 0.2.1.

## Defaults

- **Entra ID only** authentication (`azuread_administrator.azuread_authentication_only = true`)
- Public network access **disabled**
- System-assigned managed identity

## The bootstrap password

Like this repo's [sql/managed-instance](../managed-instance) Terraform module, the `azurerm` provider requires a SQL administrator password at creation even though Entra ID only authentication is enforced right after. `generate_administrator_login_password = true` lets the module generate and manage it; it's kept in state as sensitive and never output, and nobody can sign in with it once Entra ID only is on.

## SQL DB vs SQL Managed Instance vs Cosmos DB

This repo also has [sql/managed-instance](../managed-instance) and [cosmos-db/account](../../cosmos-db/account). Use this module (SQL Database) for a standard PaaS relational database with no instance-level features needed. Use Managed Instance when you need near-100% SQL Server compatibility for a lift-and-shift. Use Cosmos DB for a non-relational, globally distributed store.

## SKUs

`sku_name` accepts any valid Azure SQL Database SKU, for example `GP_S_Gen5_2` (General Purpose serverless), `GP_Gen5_4` (General Purpose provisioned), `S0`-`S12` (Standard, DTU-based) or `HS_Gen5_4` (Hyperscale).

## Usage

```hcl
module "sql_server" {
  source = "../../res/sql/server"

  name                  = "sql-orders-001"
  location              = "westeurope"
  resource_group_id     = azurerm_resource_group.this.id
  entra_admin_login     = "sql-admins"
  entra_admin_object_id = var.sql_admins_group_object_id

  databases = {
    orders = { sku_name = "GP_S_Gen5_2" }
  }

  private_endpoint = {
    subnet_resource_id            = module.network.subnet_resource_ids["private_endpoints"]
    private_dns_zone_resource_ids = [module.sql_zone.resource_id]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): serverless database and a private endpoint
