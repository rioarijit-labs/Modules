variable "name" {
  description = "Name of the Foundry resource. 2-64 characters; also used as the default custom subdomain."
  type        = string

  validation {
    condition     = length(var.name) >= 2 && length(var.name) <= 64
    error_message = "The name must be 2-64 characters."
  }
}

variable "location" {
  description = "Azure region, e.g. \"swedencentral\". Check model availability per region."
  type        = string
}

variable "resource_group_id" {
  description = "Resource ID of the resource group to deploy into, e.g. azurerm_resource_group.this.id."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "custom_subdomain_name" {
  description = "Custom subdomain for the endpoint. Required for Microsoft Entra ID authentication and private networking. Globally unique. Defaults to the resource name."
  type        = string
  default     = null
}

variable "sku_name" {
  description = "SKU of the Foundry resource."
  type        = string
  default     = "S0"
}

variable "model_deployments" {
  description = <<-EOT
    Model deployments to create, keyed by deployment name (the name applications call).
    - model: format (e.g. "OpenAI"), name (e.g. "gpt-4o") and version (e.g. "2024-11-20").
    - sku: name (e.g. "GlobalStandard", "Standard", "ProvisionedManaged") and capacity in thousands of tokens per minute (or PTUs).
  EOT
  type = map(object({
    model = object({
      format  = string
      name    = string
      version = string
    })
    sku = object({
      name     = string
      capacity = number
    })
  }))
  default = {}
}

variable "projects" {
  description = "Foundry projects to create, keyed by project name. A project is the unit teams work in (agents, evaluations, files)."
  type = map(object({
    display_name = optional(string)
    description  = optional(string)
  }))
  default = {}
}

variable "public_network_access_enabled" {
  description = "Allow public network access. False by default: reach the resource through a private endpoint."
  type        = bool
  default     = false
}

variable "local_auth_enabled" {
  description = "Allow API key authentication. False by default so only Microsoft Entra ID is accepted."
  type        = bool
  default     = false
}

variable "private_endpoint" {
  description = "Private endpoint for the resource. Leave null to skip. An object (not separate strings) so its existence is known at plan time even when the subnet is created in the same apply. private_dns_zone_resource_ids takes privatelink.cognitiveservices.azure.com, privatelink.openai.azure.com and privatelink.services.ai.azure.com."
  type = object({
    subnet_resource_id            = string
    private_dns_zone_resource_ids = optional(list(string), [])
  })
  default = null
}

variable "diagnostics" {
  description = "Send diagnostic logs and metrics to a Log Analytics workspace. Leave null to skip diagnostics. An object (not a string) so its existence is known at plan time even when the workspace is created in the same apply."
  type = object({
    workspace_resource_id = string
  })
  default = null
}

variable "user_assigned_identity_resource_ids" {
  description = "Resource IDs of user-assigned managed identities to attach, in addition to the system-assigned identity."
  type        = set(string)
  default     = []
}

variable "role_assignments" {
  description = "RBAC role assignments on the Foundry resource, keyed by an arbitrary static name, e.g. \"Cognitive Services OpenAI User\" for an app identity."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
