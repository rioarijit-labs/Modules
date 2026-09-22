variable "name" {
  description = "Name of the managed instance. 1-63 characters, lowercase letters, numbers and hyphens. Globally unique."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.name)) || can(regex("^[a-z0-9]$", var.name))
    error_message = "The name must be 1-63 characters, lowercase letters, numbers and hyphens, starting and ending with a letter or number."
  }
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
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "subnet_resource_id" {
  description = "Resource ID of the dedicated subnet. It must be delegated to Microsoft.Sql/managedInstances, be at least /27, and have the NSG and route table Managed Instance requires. See the README."
  type        = string
}

variable "entra_admin" {
  description = <<-EOT
    Microsoft Entra administrator (a group is recommended).
    - login: display name, e.g. "sql-admins".
    - object_id: object ID of the user, group or application.
    - principal_type: Group, User or Application.
  EOT
  type = object({
    login          = string
    object_id      = string
    principal_type = optional(string, "Group")
  })

  validation {
    condition     = contains(["Group", "User", "Application"], var.entra_admin.principal_type)
    error_message = "principal_type must be Group, User or Application."
  }
}

variable "sku_name" {
  description = "Tier and hardware SKU. GP_Gen5 for General Purpose, BC_Gen5 for Business Critical."
  type        = string
  default     = "GP_Gen5"

  validation {
    condition     = contains(["GP_Gen5", "BC_Gen5"], var.sku_name)
    error_message = "Use GP_Gen5 or BC_Gen5."
  }
}

variable "vcores" {
  description = "Number of vCores: 4, 8, 16, 24, 32, 40, 64 or 80."
  type        = number
  default     = 4

  validation {
    condition     = contains([4, 8, 16, 24, 32, 40, 64, 80], var.vcores)
    error_message = "Use 4, 8, 16, 24, 32, 40, 64 or 80."
  }
}

variable "storage_size_in_gb" {
  description = "Reserved storage in GB."
  type        = number
  default     = 32

  validation {
    condition     = var.storage_size_in_gb >= 32 && var.storage_size_in_gb <= 8192
    error_message = "Use a value between 32 and 8192."
  }
}

variable "license_type" {
  description = "Licensing. Use BasePrice to apply Azure Hybrid Benefit."
  type        = string
  default     = "LicenseIncluded"

  validation {
    condition     = contains(["LicenseIncluded", "BasePrice"], var.license_type)
    error_message = "Use LicenseIncluded or BasePrice."
  }
}

variable "zone_redundant" {
  description = "Spread the instance across availability zones. Business Critical or regions with zone support only."
  type        = bool
  default     = false
}

variable "backup_storage_redundancy" {
  description = "Where automated backups are stored: LRS, ZRS, GRS or GZRS."
  type        = string
  default     = "GRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS"], var.backup_storage_redundancy)
    error_message = "Use LRS, ZRS, GRS or GZRS."
  }
}

variable "database_names" {
  description = "Names of databases to create on the instance. Must be known at plan time."
  type        = set(string)
  default     = []
}

variable "diagnostics" {
  description = "Send diagnostic logs and metrics to a Log Analytics workspace. Leave null to skip diagnostics. An object (not a string) so its existence is known at plan time even when the workspace is created in the same apply."
  type = object({
    workspace_resource_id = string
  })
  default = null
}

variable "role_assignments" {
  description = "RBAC role assignments on the instance resource (management plane), keyed by an arbitrary static name."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
