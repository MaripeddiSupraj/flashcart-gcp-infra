#!/usr/bin/env bash
# Local Terraform runner matching CI backend prefixing and multi-env tfvars.
# Usage: ./scripts/tf.sh <stack-path> <dev|staging|prod> <validate|plan|apply|destroy|output>
set -euo pipefail

STACK=${1:?stack path e.g. stacks/01-network}
ENVIRONMENT=${2:?environment e.g. dev | staging | prod}
ACTION=${3:-plan}

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
ENV_FILE="$SCRIPT_DIR/backend.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE. Copy scripts/backend.env.example to scripts/backend.env first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

cd "$REPO_ROOT/$STACK"

PFX="${TF_STATE_PREFIX:-}"
PREFIX_KEY="${PFX:+${PFX}/}${STACK}/${ENVIRONMENT}"
VARS_FILE="env/${ENVIRONMENT}.tfvars"

if [[ ! -f "$VARS_FILE" ]]; then
  echo "Missing variable file: $STACK/$VARS_FILE" >&2
  exit 1
fi

if [[ "$ACTION" == "validate" ]]; then
  terraform init -backend=false
  terraform fmt -check -recursive
  terraform validate
  exit 0
fi

terraform init -reconfigure \
  -backend-config="bucket=${GCP_STATE_BUCKET}" \
  -backend-config="prefix=${PREFIX_KEY}"

case "$ACTION" in
  plan)    terraform plan -var-file="$VARS_FILE" -lock-timeout=5m ;;
  apply)   terraform apply -var-file="$VARS_FILE" -lock-timeout=5m ;;
  destroy) terraform destroy -var-file="$VARS_FILE" -lock-timeout=5m ;;
  output)  terraform output ;;
  *)
    echo "Unsupported action '$ACTION'. Use: validate | plan | apply | destroy | output" >&2
    exit 1
    ;;
esac
