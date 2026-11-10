variable "project_id" {
  description = "GCP project ID for this environment."
  type        = string
}

variable "project" {
  description = "Workload identifier prefix."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "region" {
  description = "GCP region for subnetwork and Cloud NAT."
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for Cloud Run Direct VPC egress subnet. Size to /20 before high-concurrency prod scale."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.subnet_cidr))
    error_message = "subnet_cidr must be a valid IPv4 CIDR range."
  }
}

variable "psa_prefix_length" {
  description = "Prefix length reserved for Private Service Access peering."
  type        = number
  default     = 20

  validation {
    condition     = var.psa_prefix_length >= 16 && var.psa_prefix_length <= 24
    error_message = "psa_prefix_length must be between 16 and 24."
  }
}

variable "flow_log_sampling" {
  description = "VPC Flow Log sampling rate (0.0 - 1.0)."
  type        = number
  default     = 0.5
}

variable "enabled_apis" {
  description = "GCP APIs enabled in the environment project."
  type        = list(string)
}

