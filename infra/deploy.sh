#!/bin/bash
# Deploy the LobeChat CloudFormation stack.
# Run from the repo root: bash infra/deploy.sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/config.local"

if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: $CONFIG not found."
  echo "  cp infra/config.local.example infra/config.local"
  echo "  # fill in your values, then re-run"
  exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG"

: "${KEY_NAME:?KEY_NAME not set in config.local}"
: "${GITHUB_TOKEN:?GITHUB_TOKEN not set in config.local}"
: "${OPENROUTER_API_KEY:?OPENROUTER_API_KEY not set in config.local}"
: "${DUCKDNS_TOKEN:?DUCKDNS_TOKEN not set in config.local}"
: "${MINIO_ROOT_PASSWORD:?MINIO_ROOT_PASSWORD not set in config.local}"

echo "=== Deploying lobechat CloudFormation stack ==="

aws cloudformation deploy \
  --region eu-west-1 \
  --template-file "$SCRIPT_DIR/cloudformation.yml" \
  --stack-name lobechat \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    KeyName="$KEY_NAME" \
    GithubToken="$GITHUB_TOKEN" \
    OpenrouterApiKey="$OPENROUTER_API_KEY" \
    DuckdnsToken="$DUCKDNS_TOKEN" \
    MinioRootPassword="$MINIO_ROOT_PASSWORD"

echo ""
echo "=== Stack deployed. Outputs: ==="
aws cloudformation describe-stacks \
  --region eu-west-1 \
  --stack-name lobechat \
  --query 'Stacks[0].Outputs' \
  --output table
