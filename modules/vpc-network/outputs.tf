output "network_id" {
  value = google_compute_network.vpc.id
}

output "network_name" {
  value = google_compute_network.vpc.name
}

output "subnet_id" {
  value = google_compute_subnetwork.run.id
}

output "psa_range_name" {
  value = google_compute_global_address.psa.name
}

