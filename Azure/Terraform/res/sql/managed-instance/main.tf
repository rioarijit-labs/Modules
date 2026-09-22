data "azurerm_client_config" "current" {}

# The provider requires a SQL administrator when the instance is created. Microsoft Entra only
# authentication is enforced right after, so this password is never used to sign in. It is generated,
# kept in state as sensitive, and never output.
resource "random_password" "bootstrap_admin" {
  length           = 40
  special          = true
  override_special = "!#$%*-_=+"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}

locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  databases = {
    for database_name in var.database_names : database_name => {
      name = database_name
    }
  }

  diagnostic_settings = var.diagnostics == null ? {} : {
    default = {
      workspace_resource_id = var.diagnostics.workspace_resource_id
    }
  }
}

module "managed_instance" {
  source  = "Azure/avm-res-sql-managedinstance/azurerm"
  version = "0.3.1"

  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
  subnet_id           = var.subnet_resource_id

  sku_name               = var.sku_name
  vcores                 = var.vcores
  storage_size_in_gb     = var.storage_size_in_gb
  license_type           = var.license_type
  storage_account_type   = var.backup_storage_redundancy
  zone_redundant_enabled = var.zone_redundant

  # Secure defaults: Entra ID only, no public data endpoint, TLS 1.2
  administrator_login          = "sqlbootstrapadmin"
  administrator_login_password = random_password.bootstrap_admin.result
  active_directory_administrator = {
    login_username                      = var.entra_admin.login
    object_id                           = var.entra_admin.object_id
    principal_type                      = var.entra_admin.principal_type
    tenant_id                           = data.azurerm_client_config.current.tenant_id
    azuread_authentication_only_enabled = true
  }
  public_data_endpoint_enabled = false
  minimum_tls_version          = "1.2"

  # The instance identity is used to read Entra ID; grant it the "Directory Readers" role
  managed_identities = {
    system_assigned = true
  }
  databases           = local.databases
  diagnostic_settings = local.diagnostic_settings
  role_assignments    = var.role_assignments
}
