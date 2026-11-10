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

variable "subnet_cidr" {
  description = "CIDR block for Cloud Run Direct VPC egress subnet."
  type        = string
  default     = "10.40.0.0/24"
}

variable "psa_prefix_length" {
  description = "Private Service Access prefix length for Cloud SQL / AlloyDB."
  type        = number
  default     = 20
}

variable "flow_log_sampling" {
  description = "VPC Flow Log sampling ratio."
  type        = number
  default     = 0.5
}

