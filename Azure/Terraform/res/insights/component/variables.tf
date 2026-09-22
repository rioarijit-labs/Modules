variable "name" {
  description = "Name of the Application Insights component."
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
  description = "Tags applied to the component."
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace this component stores its data in. Workspace-based is the only supported mode; classic (standalone) Application Insights is retired."
  type        = string
}

variable "application_type" {
  description = "web covers both web and non-web apps; other is used for some client SDK scenarios."
  type        = string
  default     = "web"

  validation {
    condition     = contains(["web", "other"], var.application_type)
    error_message = "Use web or other."
  }
}

variable "retention_in_days" {
  description = "Days to retain telemetry. Independent of the underlying workspace's own retention."
  type        = number
  default     = 90

  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "Use a value between 30 and 730."
  }
}

variable "sampling_percentage" {
  description = "Percentage of telemetry to sample, to control cost on high-volume apps. 100 means no sampling."
  type        = number
  default     = 100

  validation {
    condition     = var.sampling_percentage >= 0 && var.sampling_percentage <= 100
    error_message = "Use a value between 0 and 100."
  }
}

variable "internet_ingestion_enabled" {
  description = "Allow public network access for ingestion (the SDK sending telemetry). Disabling it requires an Azure Monitor Private Link Scope, otherwise telemetry stops arriving."
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Allow public network access for queries (reading telemetry, e.g. from the portal or an API). Disabling it requires an Azure Monitor Private Link Scope."
  type        = bool
  default     = true
}

variable "local_authentication_disabled" {
  description = "Disable API key based ingestion and access. Applications should send telemetry with Entra ID / Azure Monitor OpenTelemetry authentication instead."
  type        = bool
  default     = false
}

variable "role_assignments" {
  description = "RBAC role assignments on the component, keyed by an arbitrary static name, e.g. \"Monitoring Reader\" for a support group."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  default = {}
}
