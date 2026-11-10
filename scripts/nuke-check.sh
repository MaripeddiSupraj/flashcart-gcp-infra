#!/usr/bin/env bash
# End-of-day GCP billing audit: lists resources that continue billing if left up.
set -uo pipefail

PROJECT_ID="${1:-ritru-fc-dev-01}"
REGION="${GCP_REGION:-asia-south1}"

echo "== Checking billing resources in GCP project: ${PROJECT_ID} (region: ${REGION}) =="
gcloud compute instances list --project="$PROJECT_ID" --format='table(name,zone,status)' 2>/dev/null || true
gcloud sql instances list --project="$PROJECT_ID" --format='table(name,region,state,settings.tier)' 2>/dev/null || true
gcloud alloydb clusters list --region="$REGION" --project="$PROJECT_ID" 2>/dev/null || true
gcloud compute forwarding-rules list --project="$PROJECT_ID" --format='table(name,region,IPAddress)' 2>/dev/null || true
gcloud compute routers list --project="$PROJECT_ID" --format='table(name,region)' 2>/dev/null || true
gcloud run services list --project="$PROJECT_ID" --format='table(metadata.name,region,status.url)' 2>/dev/null || true
gcloud scheduler jobs list --location="$REGION" --project="$PROJECT_ID" --format='table(name,schedule,state)' 2>/dev/null || true
