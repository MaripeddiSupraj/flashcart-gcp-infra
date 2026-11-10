# FlashCart GCP Infra (`gcp/02-flashcart-serverless-saga`)

Enterprise multi-environment Terraform repository for the **FlashCart Serverless E-Commerce & Saga Engine** on Google Cloud.

## Current Status
- **Completed & Modularized:**
  - `modules/vpc-network` + `stacks/01-network` (14 GCP APIs, custom regional VPC, Direct VPC Egress subnet, PSA `/20` peering, Cloud Router + NAT, IAP-only SSH firewall)
  - `modules/data-tier` + `stacks/02-data` (Firestore Native with PITR, Pub/Sub Avro schema + topic + DLQ, Cloud SQL PostgreSQL 16 private-IP with IAM Auth, hardened GCS invoices bucket)
  - Shared `.github/workflows/` (`infra.yml`, `terraform-stack.yml`, `drift.yml`), OPA Conftest `policies/*.rego`, `.tflint.hcl`, `.pre-commit-config.yaml`, `scripts/tf.sh`, `scripts/nuke-check.sh`
- **Remaining Stacks to Build Next:**
  - `stacks/03-app` (Artifact Registry, per-service SAs, Cloud SQL IAM DB users, Cloud Run `checkout-api`, `catalog-read-svc`, `inventory-svc`, Cloud Workflows `order-saga`, Eventarc trigger)
  - `stacks/04-edge` (Serverless NEGs, Cloud Armor WAF + rate limiting, Cloud CDN on catalog, Global External ALB + optional Google-managed TLS)
  - `stacks/05-extras` (Cloud Deploy canary pipeline + Monitoring alerts, Zero-ETL BigQuery Pub/Sub subscription, Cloud Run Jobs `outbox-relay` + `fulfillment-job`, Cloud Scheduler, OTel Secret, optional AlloyDB)

## Foundation & State Configuration
- **Bootstrap repo:** `MaripeddiSupraj/gcp-foundation`
- **Remote GCS State Bucket:** `ritru-tfstate-586582398977`
- **State Prefix (`TF_STATE_PREFIX`):** `gcp-02-flashcart`
- **Live Dev Project:** `ritru-fc-dev-01`
- **GitHub OIDC Plan SA:** `ritru-tf-plan@ritru-tf-seed-01.iam.gserviceaccount.com`
- **GitHub OIDC Dev Apply SA:** `ritru-tf-apply-dev@ritru-tf-seed-01.iam.gserviceaccount.com`

## Local Usage
```bash
cp scripts/backend.env.example scripts/backend.env
# Fill GCP_STATE_BUCKET and TF_STATE_PREFIX=gcp-02-flashcart

./scripts/tf.sh stacks/01-network dev plan
./scripts/tf.sh stacks/01-network dev apply
```
