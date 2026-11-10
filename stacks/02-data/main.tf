module "data" {
  source = "../../modules/data-tier"

  project_id          = var.project_id
  project             = var.project
  environment         = var.environment
  region              = var.region
  sql_tier            = var.sql_tier
  sql_ha              = var.sql_ha
  deletion_protection = var.deletion_protection
}

