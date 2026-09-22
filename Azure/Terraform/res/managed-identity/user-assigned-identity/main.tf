locals {
  resource_group_name = element(split("/", var.resource_group_id), 4)

  federated_identity_credentials = {
    for credential_name, credential in var.federated_identity_credentials : credential_name => {
      name     = credential_name
      issuer   = credential.issuer
      subject  = credential.subject
      audience = length(credential.audiences) > 0 ? credential.audiences : ["api://AzureADTokenExchange"]
    }
  }
}

module "user_assigned_identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.5.2"

  name                           = var.name
  location                       = var.location
  resource_group_name            = local.resource_group_name
  tags                           = var.tags
  federated_identity_credentials = local.federated_identity_credentials
  role_assignments               = var.role_assignments
}
