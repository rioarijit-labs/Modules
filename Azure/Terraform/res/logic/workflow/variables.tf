variable "name" {
  description = "Name of the workflow."
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
  description = "Tags applied to the workflow."
  type        = map(string)
  default     = {}
}

variable "triggers" {
  description = "Trigger definitions, in Workflow Definition Language, e.g. { manual = { type = \"Request\", kind = \"Http\", inputs = { schema = {} } } }. Free-form: Logic Apps has no fixed schema for this."
  type        = any
  default     = {}
}

variable "actions" {
  description = "Action definitions, in Workflow Definition Language."
  type        = any
  default     = {}
}

variable "workflow_parameters" {
  description = "Workflow-level parameters (Workflow Definition Language \"parameters\" block), referenced from triggers/actions with @parameters('name')."
  type        = any
  default     = {}
}

variable "state" {
  description = "Enabled runs the workflow on its triggers. Disabled keeps the resource but stops it running, useful while you finish wiring connections."
  type        = string
  default     = "Enabled"

  validation {
    condition     = contains(["Enabled", "Disabled"], var.state)
    error_message = "Use Enabled or Disabled."
  }
}

variable "enable_system_assigned_identity" {
  description = "Enable the system-assigned managed identity, used by connectors that authenticate with Entra ID instead of a connection secret."
  type        = bool
  default     = true
}

variable "user_assigned_identity_resource_ids" {
  description = "Resource IDs of user-assigned managed identities to attach."
  type        = set(string)
  default     = []
}

variable "role_assignments" {
  description = "RBAC role assignments on the workflow resource (management plane), keyed by an arbitrary static name."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
