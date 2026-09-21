# SQL Managed Instance

Azure SQL Managed Instance in your VNet. Wraps `Azure/avm-res-sql-managedinstance/azurerm` 0.3.1.

## Defaults

- **Entra ID only** authentication: `azuread_authentication_only_enabled = true`
- No public data endpoint, TLS 1.2
- General Purpose, 4 vCores, 32 GB
- System-assigned managed identity

## The bootstrap password

The `azurerm` provider requires a SQL administrator login and password when an instance is created, even though Entra ID only authentication is enforced right after. The module generates a random password (`random_password`), passes it to the instance, and never outputs it. Nobody can sign in with it once Entra ID only is on. It is kept in Terraform state as a sensitive value, so protect the state.

## Prerequisites

- **Dedicated subnet**, at least `/27`, delegated to `Microsoft.Sql/managedInstances`, with a network security group and a route table associated. Create it with the `virtual-network` module (`delegation`, `network_security_group_resource_id`, `route_table_resource_id`). Managed Instance adds the rules it needs to them itself.
- **Directory Readers.** Entra ID authentication only works once the instance identity (the `system_assigned_mi_principal_id` output) has the Entra role `Directory Readers`. Grant it after deployment, or give the role to a group that contains the identity.
- **Time and cost.** The first instance in a subnet can take several hours to deploy, and the instance is billed while it exists. Test the contract with the validator, and deploy for real only when you need to.

## Notes

- Application connections use the instance's private FQDN. There is no private endpoint, since the instance already lives in the VNet.
- `sku_name` picks the tier: `GP_Gen5` is General Purpose and `BC_Gen5` is Business Critical.

## Usage

```hcl
module "sql_mi" {
  source = "../../res/sql/managed-instance"

  name               = "sqlmi-orders-001"
  location           = "westeurope"
  resource_group_id  = azurerm_resource_group.this.id
  subnet_resource_id = module.network.subnet_resource_ids["sqlmi"]

  entra_admin = {
    login     = "sql-admins"
    object_id = var.sql_admins_group_object_id
  }

  database_names = ["orders"]
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): General Purpose instance with an Entra admin group and one database
