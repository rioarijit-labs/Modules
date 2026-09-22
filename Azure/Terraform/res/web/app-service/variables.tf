variable "name" {
  description = "Name of the app. Globally unique, it forms <name>.azurewebsites.net."
  type        = string

  validation {
    condition     = length(var.name) >= 2 && length(var.name) <= 60
    error_message = "The name must be 2-60 characters."
  }
}

variable "location" {
  description = "Azure region, e.g. \"westeurope\". Must match the App Service plan."
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

variable "service_plan_resource_id" {
  description = "Resource ID of the App Service plan to run on."
  type        = string
}

variable "kind" {
  description = "Kind of app: webapp or functionapp."
  type        = string
  default     = "webapp"

  validation {
    condition     = contains(["webapp", "functionapp"], var.kind)
    error_message = "Use webapp or functionapp."
  }
}

variable "os_type" {
  description = "Operating system of the app. It must match the App Service plan."
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "Use Linux or Windows."
  }
}

variable "linux_fx_version" {
  description = "Runtime stack for Linux apps, e.g. \"NODE|20-lts\", \"PYTHON|3.12\", \"DOTNETCORE|9.0\". Leave null for Windows apps."
  type        = string
  default     = null
}

variable "always_on" {
  description = "Keep the app loaded. Requires Basic tier or above."
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Path the platform probes to check instance health, e.g. \"/healthz\". Leave null to disable."
  type        = string
  default     = null
}

variable "app_settings" {
  description = "Application settings. Use Key Vault references (@Microsoft.KeyVault(...)) for secrets, never plain values."
  type        = map(string)
  default     = {}
}

variable "public_network_access_enabled" {
  description = "Allow public network access. False by default: reach the app through a private endpoint. Set to true for internet-facing apps."
  type        = bool
  default     = false
}

variable "virtual_network_subnet_resource_id" {
  description = "Subnet resource ID for regional VNet integration (outbound traffic). The subnet must be delegated to Microsoft.Web/serverFarms. Leave null to skip."
  type        = string
  default     = null
}

variable "private_endpoint" {
  description = "Private endpoint for inbound traffic. Leave null to skip. An object (not separate strings) so its existence is known at plan time even when the subnet is created in the same apply. private_dns_zone_resource_ids takes e.g. privatelink.azurewebsites.net."
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

variable "enable_system_assigned_identity" {
  description = "Enable the system-assigned managed identity."
  type        = bool
  default     = true
}

variable "user_assigned_identity_resource_ids" {
  description = "Resource IDs of user-assigned managed identities to attach."
  type        = set(string)
  default     = []
}

variable "role_assignments" {
  description = "RBAC role assignments on the app, keyed by an arbitrary static name."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
