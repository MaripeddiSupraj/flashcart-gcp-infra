terraform {
  required_version = ">= 1.11"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.0"
    }
  }
}

locals {
  name = "${var.project}-${var.environment}"
}

# Cross-stack lookup by deterministic name instead of reading 01-network state directly.
data "google_compute_network" "vpc" {
  name    = local.name
  project = var.project_id
}

# ---------- Firestore (Native mode): Orders + Idempotency Keys ----------
resource "google_firestore_database" "orders" {
  project                           = var.project_id
  name                              = "(default)"
  location_id                       = var.region
  type                              = "FIRESTORE_NATIVE"
  point_in_time_recovery_enablement = "POINT_IN_TIME_RECOVERY_ENABLED"
  delete_protection_state           = var.deletion_protection ? "DELETE_PROTECTION_ENABLED" : "DELETE_PROTECTION_DISABLED"
  deletion_policy                   = var.deletion_protection ? "ABANDON" : "DELETE"
}

# ---------- Pub/Sub: Avro Schema Enforcement + Main Topic + Dead-Letter ----------
resource "google_pubsub_schema" "order_created" {
  project = var.project_id
  name    = "order-created-v1"
  type    = "AVRO"
  definition = jsonencode({
    type = "record"
    name = "OrderCreated"
    fields = [
      { name = "order_id", type = "string" },
      { name = "customer_id", type = "string" },
      { name = "sku", type = "string" },
      { name = "qty", type = "int" },
      { name = "amount_cents", type = "long" },
    ]
  })
}

resource "google_pubsub_topic" "orders_created" {
  project                    = var.project_id
  name                       = "orders-created-v1"
  message_retention_duration = "86400s"

  schema_settings {
    schema   = google_pubsub_schema.order_created.id
    encoding = "JSON"
  }
}

resource "google_pubsub_topic" "orders_dlq" {
  project = var.project_id
  name    = "orders-created-v1-dlq"
}

resource "google_pubsub_subscription" "orders_dlq_pull" {
  project                    = var.project_id
  name                       = "orders-created-v1-dlq-inspect"
  topic                      = google_pubsub_topic.orders_dlq.id
  message_retention_duration = "604800s"
}

# ---------- Cloud SQL PostgreSQL 16 (Private IP only, IAM Auth, PITR) ----------
resource "google_sql_database_instance" "inventory" {
  project             = var.project_id
  name                = "${local.name}-inventory"
  database_version    = "POSTGRES_16"
  region              = var.region
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.sql_tier
    edition           = "ENTERPRISE"
    availability_type = var.sql_ha ? "REGIONAL" : "ZONAL"
    disk_autoresize   = true

    ip_configuration {
      ipv4_enabled    = false
      private_network = data.google_compute_network.vpc.id
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "20:30" # 02:00 IST
    }

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }

    insights_config {
      query_insights_enabled = true
    }
  }
}

resource "google_sql_database" "inventory" {
  project  = var.project_id
  name     = "inventory"
  instance = google_sql_database_instance.inventory.name
}

# ---------- Hardened Invoices GCS Bucket ----------
resource "google_storage_bucket" "invoices" {
  project                     = var.project_id
  name                        = "${local.name}-invoices-${var.project_id}"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = !var.deletion_protection

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
}

