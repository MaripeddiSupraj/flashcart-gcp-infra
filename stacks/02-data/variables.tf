variable "project_id" {
  description = "GCP project ID for this environment."
  type        = string
}

variable "project" {
  description = "Workload name prefix."
  type        = string
  default     = "flashcart"
}

variable "environment" {
  description = "Target environment (dev, staging, prod)."
  type        = string
}

variable "region" {
  description = "GCP region."
  type        = string
  default     = "asia-south1"
}

variable "owner" {
  description = "Owning team label."
  type        = string
}

variable "sql_tier" {
  description = "Cloud SQL machine tier."
  type        = string
  default     = "db-custom-1-3840"
}

variable "sql_ha" {
  description = "Enable REGIONAL HA failover replica."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Protect databases and buckets from accidental deletion."
  type        = bool
  default     = false
}

