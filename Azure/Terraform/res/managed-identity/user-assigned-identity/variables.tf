variable "name" {
  description = "Name of the managed identity."
  type        = string
}

variable "location" {
  description = "Azure region, e.g. \"westeurope\"."
  type        = string
}

variable "resource_group_id" {
  description = "Resource ID of the resource group to deploy into, e.g. azurerm_resource_group.this.id."
  type        = string
}

variable "tags" {
  description = "Tags applied to the identity."
  type        = map(string)
  default     = {}
}

variable "federated_identity_credentials" {
  description = <<-EOT
    Federated identity credentials, keyed by an arbitrary static name, trusting tokens from an external OIDC issuer
    (e.g. a Kubernetes service account or a GitHub Actions workflow) without a client secret.
    - issuer: token issuer URL, e.g. the AKS OIDC issuer URL or "https://token.actions.githubusercontent.com".
    - subject: expected subject claim, e.g. "system:serviceaccount:<namespace>:<service-account>" for Kubernetes.
    - audiences: expected audience claims. Use ["api://AzureADTokenExchange"], the standard audience for Entra workload identity federation, unless the issuer requires something else.
  EOT
  type = map(object({
    issuer    = string
    subject   = string
    audiences = list(string)
  }))
  default = {}
}

variable "role_assignments" {
  description = <<-EOT
    RBAC role assignments granted TO this identity, keyed by an arbitrary static name. Unlike every other
    module's role_assignments in this repo, there is no principal_id here: the principal is always this
    identity itself. Supply scope (the resource, resource group or subscription the role applies to) and which
    role, e.g. { scope = azurerm_storage_account.this.id, role_definition_id_or_name = "Storage Blob Data Contributor" }.
  EOT
  type = map(object({
    role_definition_id_or_name = string
    scope                      = string
    description                = optional(string)
    condition                  = optional(string)
  }))
  default = {}
}
