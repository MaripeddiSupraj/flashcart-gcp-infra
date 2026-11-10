output "sql_connection_name" {
  description = "Cloud SQL connection name for Python connector."
  value       = google_sql_database_instance.inventory.connection_name
}

output "sql_private_ip" {
  description = "Private PSA IP of Cloud SQL PostgreSQL."
  value       = google_sql_database_instance.inventory.private_ip_address
}

output "orders_topic" {
  description = "Pub/Sub orders topic resource ID."
  value       = google_pubsub_topic.orders_created.id
}

output "invoices_bucket" {
  description = "Hardened GCS bucket name for generated invoices."
  value       = google_storage_bucket.invoices.name
}

