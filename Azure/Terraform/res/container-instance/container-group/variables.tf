variable "name" {
  description = "Name of the container group."
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
  description = "Tags applied to the container group."
  type        = map(string)
  default     = {}
}

variable "containers" {
  description = "Containers to run in the group, keyed by container name. They share the same network namespace and can reach each other over localhost."
  type = map(object({
    image                        = string
    cpu                          = number
    memory                       = number
    ports                        = optional(list(number), [])
    commands                     = optional(list(string))
    environment_variables        = optional(map(string), {})
    secure_environment_variables = optional(map(string), {})
  }))

  validation {
    condition     = length(var.containers) > 0
    error_message = "Define at least one container."
  }
}

variable "os_type" {
  description = "Operating system."
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "Use Linux or Windows."
  }
}

variable "restart_policy" {
  description = "What Azure does if a container exits. Always for a long-running service, Never for a one-off job, OnFailure for a retryable job."
  type        = string
  default     = "Always"

  validation {
    condition     = contains(["Always", "Never", "OnFailure"], var.restart_policy)
    error_message = "Use Always, Never or OnFailure."
  }
}

variable "subnet_resource_id" {
  description = "Subnet resource ID to place the container group in. Required for any private networking; container instances have no separate private endpoint concept for their own placement, they live directly in the subnet."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID (the workspace customer ID, not the resource ID) for container stdout/stderr logs. Leave empty to skip."
  type        = string
  default     = ""
}

variable "log_analytics_workspace_key" {
  description = "Primary shared key of the Log Analytics workspace named in log_analytics_workspace_id. Required together with it. Read this from Key Vault or a secure variable, never hard-code it."
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_system_assigned_identity" {
  description = "Enable the system-assigned managed identity."
  type        = bool
  default     = false
}

variable "user_assigned_identity_resource_ids" {
  description = "Resource IDs of user-assigned managed identities to attach, e.g. one with AcrPull for a private registry."
  type        = set(string)
  default     = []
}

variable "role_assignments" {
  description = "RBAC role assignments on the container group, keyed by an arbitrary static name."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
