variable "name" {
  description = "Name of the Cosmos DB account. 3-44 characters, lowercase letters, numbers and hyphens. Globally unique."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,42}[a-z0-9]$", var.name))
    error_message = "The name must be 3-44 characters, lowercase letters, numbers and hyphens, starting and ending with a letter or number."
  }
}

variable "location" {
  description = "Azure region for the primary (write) location, e.g. \"westeurope\"."
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

variable "additional_locations" {
  description = "Additional read regions, as region names, e.g. [\"westus2\"]. Requires zone_redundant and enable_automatic_failover to matter; leave empty for a single-region account."
  type        = list(string)
  default     = []
}

variable "zone_redundant" {
  description = "Spread each region across availability zones. Not available in every region."
  type        = bool
  default     = false
}

variable "enable_automatic_failover" {
  description = "Promote a read region to primary automatically if the write region fails. Needs at least one entry in additional_locations."
  type        = bool
  default     = false
}

variable "consistency_level" {
  description = "Consistency guarantee for reads. Session is the right default for most apps; Strong costs the most latency and RU."
  type        = string
  default     = "Session"

  validation {
    condition     = contains(["Eventual", "ConsistentPrefix", "Session", "BoundedStaleness", "Strong"], var.consistency_level)
    error_message = "Use one of Eventual, ConsistentPrefix, Session, BoundedStaleness, Strong."
  }
}

variable "serverless" {
  description = "Pay per request instead of reserving RU/s. Capped at 5000 RU/s total and incompatible with free_tier_enabled and with per-container throughput. Cheaper for spiky, low-traffic or dev workloads."
  type        = bool
  default     = false
}

variable "free_tier_enabled" {
  description = "Apply the subscription's one free tier (1000 RU/s and 25 GB) to this account. Only one account per subscription can use it, and it fails deployment if another already has it."
  type        = bool
  default     = false
}

variable "backup_policy_type" {
  description = "Continuous enables point-in-time restore. Periodic takes scheduled snapshots and is cheaper for large, rarely-restored accounts."
  type        = string
  default     = "Continuous"

  validation {
    condition     = contains(["Continuous", "Periodic"], var.backup_policy_type)
    error_message = "Use Continuous or Periodic."
  }
}

variable "sql_databases" {
  description = "SQL (Core) API databases to create, keyed by database name. Containers are keyed by container name."
  type = map(object({
    throughput = optional(number)
    containers = map(object({
      partition_key_paths = list(string)
      throughput          = optional(number)
      default_ttl_seconds = optional(number)
    }))
  }))
  default = {}
}

variable "public_network_access_enabled" {
  description = "Allow public network access. False by default: reach the account through a private endpoint."
  type        = bool
  default     = false
}

variable "private_endpoint" {
  description = "Private endpoint for the account. Leave null to skip. An object (not separate strings) so its existence is known at plan time even when the subnet is created in the same apply. private_dns_zone_resource_ids takes e.g. privatelink.documents.azure.com."
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
  default     = false
}

variable "user_assigned_identity_resource_ids" {
  description = "Resource IDs of user-assigned managed identities to attach."
  type        = set(string)
  default     = []
}

variable "role_assignments" {
  description = "Azure RBAC role assignments on the account resource, keyed by an arbitrary static name (management plane only, e.g. \"Cosmos DB Account Reader Role\"). This does not grant data access: use data_role_assignments for that."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}

variable "data_role_assignments" {
  description = <<-EOT
    Data-plane role assignments through Cosmos DB's own SQL RBAC, keyed by an arbitrary static name. Required for
    any application to read or write data, since local (key-based) authentication is always disabled. The upstream
    Terraform AVM module does not create these yet, so this module creates them directly as
    azurerm_cosmosdb_sql_role_assignment resources.
    - role: Reader can query and read items. Contributor can also create, update and delete.
  EOT
  type = map(object({
    principal_id = string
    role         = string
  }))
  default = {}

  validation {
    condition     = alltrue([for a in values(var.data_role_assignments) : contains(["Reader", "Contributor"], a.role)])
    error_message = "role must be Reader or Contributor."
  }
}
