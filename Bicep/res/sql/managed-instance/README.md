# SQL Managed Instance

Azure SQL Managed Instance in your VNet. Wraps `br/public:avm/res/sql/managed-instance:0.5.0`.

## Defaults

- **Entra ID only** authentication: no SQL logins, no SQL admin password anywhere
- No public data endpoint, TLS 1.2
- General Purpose, 4 vCores, 32 GB
- System-assigned managed identity

## Prerequisites

- **Dedicated subnet**, at least `/27`, delegated to `Microsoft.Sql/managedInstances`, with a network security group and a route table associated. Create it with the `virtual-network` module (`delegation`, `networkSecurityGroupResourceId`, `routeTableResourceId`). Managed Instance adds the rules it needs to them itself.
- **Directory Readers.** Entra ID authentication only works once the instance identity (the `systemAssignedMIPrincipalId` output) has the Entra role `Directory Readers`. Grant it after deployment, or give the role to a group that contains the identity.
- **Time and cost.** The first instance in a subnet can take several hours to deploy, and the instance is billed while it exists. Test the contract with the validator, and deploy for real only when you need to.

## Notes

- Application connections use the instance's private FQDN. There is no private endpoint, since the instance already lives in the VNet.
- Choose `skuTier` and `skuName` together: `GeneralPurpose` with `GP_Gen5`, `BusinessCritical` with `BC_Gen5`.

## Usage

```bicep
module sqlMi '../../res/sql/managed-instance/main.bicep' = {
  name: 'sqlmi'
  params: {
    name: 'sqlmi-orders-001'
    subnetResourceId: vnet.outputs.subnetResourceIds[3]
    entraAdminLogin: 'sql-admins'
    entraAdminObjectId: sqlAdminsGroupObjectId
    databaseNames: ['orders']
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): General Purpose instance with an Entra admin group and one database
