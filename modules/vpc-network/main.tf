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

resource "google_project_service" "apis" {
  for_each           = toset(var.enabled_apis)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

resource "google_compute_network" "vpc" {
  name                    = local.name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  depends_on              = [google_project_service.apis]
}

resource "google_compute_subnetwork" "run" {
  name                     = "${local.name}-run"
  project                  = var.project_id
  network                  = google_compute_network.vpc.id
  region                   = var.region
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = var.flow_log_sampling
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Private Service Access (PSA): Google-managed peering range for Cloud SQL / AlloyDB private IPs.
resource "google_compute_global_address" "psa" {
  name          = "${local.name}-psa"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.psa_prefix_length
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "psa" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa.name]
}

# Cloud NAT serves private-subnet VMs (e.g. temporary IAP jump host).
# Cloud Run uses Direct VPC egress with PRIVATE_RANGES_ONLY, so public Google API calls bypass NAT.
resource "google_compute_router" "nat" {
  name    = "${local.name}-router"
  project = var.project_id
  network = google_compute_network.vpc.id
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "${local.name}-nat"
  project                            = var.project_id
  router                             = google_compute_router.nat.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.run.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Zero-trust SSH: permit TCP 22 solely from Google Identity-Aware Proxy (35.235.240.0/20).
resource "google_compute_firewall" "allow_iap_ssh" {
  name          = "${local.name}-allow-iap-ssh"
  project       = var.project_id
  network       = google_compute_network.vpc.name
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

