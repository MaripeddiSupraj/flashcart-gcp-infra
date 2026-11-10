locals {
  apis = [
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "firestore.googleapis.com",
    "pubsub.googleapis.com",
    "workflows.googleapis.com",
    "workflowexecutions.googleapis.com",
    "eventarc.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudkms.googleapis.com",
    "iap.googleapis.com",
    "certificatemanager.googleapis.com",
  ]
}

module "network" {
  source = "../../modules/vpc-network"

  project_id        = var.project_id
  project           = var.project
  environment       = var.environment
  region            = var.region
  subnet_cidr       = var.subnet_cidr
  psa_prefix_length = var.psa_prefix_length
  flow_log_sampling = var.flow_log_sampling
  enabled_apis      = local.apis
}

