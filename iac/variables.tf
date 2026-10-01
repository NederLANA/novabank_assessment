# ---------------------------------------------------------------
# variables.tf  -  the "knobs" you can turn per environment
# SAY: "Dev and prod use the same code. Only the values in envs/*.tfvars differ."
# ---------------------------------------------------------------
variable "subscription_id" {
  type        = string
  description = "Azure subscription ID (run: az account show --query id -o tsv)"
}

variable "project" {
  type    = string
  default = "novabank"
}

variable "environment" {
  type        = string
  description = "dev or prod"
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

variable "location" {
  type        = string
  default     = "westeurope" # Netherlands. If PostgreSQL is restricted for your new subscription, try northeurope / germanywestcentral / swedencentral
  description = "Azure region for all resources (must be in allowed_locations)"
}

variable "allowed_locations" {
  type        = list(string)
  default     = ["westeurope", "northeurope", "germanywestcentral", "swedencentral"]
  description = "EU-only regions enforced by Azure Policy"
}

variable "owner" {
  type        = string
  description = "Your name or team - used in the required 'owner' tag"
}

variable "container_image" {
  type        = string
  description = "Full image name, e.g. ghcr.io/<github-user-lowercase>/novabank-api:latest"
}

variable "db_admin_user" {
  type    = string
  default = "psqladmin"
}

variable "log_retention_days" {
  type        = number
  default     = 365 # brief: logs retained >= 12 months
  description = "Log Analytics retention (allowed: 7, or 30-730)"
}

variable "daily_quota_gb" {
  type        = number
  default     = 1 # cost guard for dev. -1 = unlimited (used for prod so audit logs are not dropped)
  description = "Daily log ingestion cap in GB"
}

variable "min_replicas" {
  type    = number
  default = 0
}

variable "max_replicas" {
  type    = number
  default = 3
}

variable "enable_budget" {
  type        = bool
  default     = false # budgets may not be supported on every free/trial subscription; create in portal if it fails
  description = "Create an Azure cost budget + alert on the resource group"
}

variable "budget_amount" {
  type    = number
  default = 10
}

variable "budget_start_date" {
  type        = string
  default     = "2026-10-01T00:00:00Z" # must be the first day of a month
  description = "Budget start date"
}

variable "budget_email" {
  type        = string
  default     = "you@example.com"
  description = "Email for the budget alert"
}
