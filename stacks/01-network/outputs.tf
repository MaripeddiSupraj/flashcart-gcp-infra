output "network_id" {
  description = "VPC resource ID."
  value       = module.network.network_id
}

output "network_name" {
  description = "Deterministic VPC name consumed by downstream stacks."
  value       = module.network.network_name
}

output "subnet_id" {
  description = "Cloud Run Direct VPC egress subnet ID."
  value       = module.network.subnet_id
}

output "psa_range_name" {
  description = "Allocated Private Service Access peering range name."
  value       = module.network.psa_range_name
}

