variable "project_id" {
  description = "GCP project ID for this environment."
  type        = string
}

variable "project" {
  description = "Workload name prefix."
  type        = string
}

variable "environment" {
  description = "Target environment (dev, staging, prod)."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "region" {
  description = "GCP region."
  type        = string
}

variable "sql_tier" {
  description = "Cloud SQL machine tier. Size connections vs Cloud Run max_instance_count."
  type        = string
  default     = "db-custom-1-3840"
}

variable "sql_ha" {
  description = "Use REGIONAL high availability in prod; ZONAL in dev/staging."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Protect stateful databases and storage buckets against accidental deletion."
  type        = bool
  default     = false
}

