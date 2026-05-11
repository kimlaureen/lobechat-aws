#!/bin/bash
# NOTE: This script is kept for reference only.
# The ESADE sandbox role does not have ssm:PutParameter permission.
# Secrets are instead passed as CloudFormation parameters via infra/deploy.sh
# reading from infra/config.local (gitignored).
#
# If running in an environment with SSM write access, fill in the values
# from infra/config.local.example and run this script once before deploying.
set -e

REGION=eu-west-1

echo "=== Storing secrets in SSM Parameter Store (region: $REGION) ==="

put() {
  aws ssm put-parameter \
    --region "$REGION" \
    --name "$1" \
    --value "$2" \
    --type SecureString \
    --overwrite \
    --no-cli-pager
  echo "  ✓ $1"
}

# Generate random secrets
KEY_VAULTS_SECRET=$(openssl rand -base64 32)
NEXT_AUTH_SECRET=$(openssl rand -base64 32)
POSTGRES_PASSWORD=$(openssl rand -hex 16)

put /lobechat/key-vaults-secret   "$KEY_VAULTS_SECRET"
put /lobechat/next-auth-secret    "$NEXT_AUTH_SECRET"
put /lobechat/postgres-password   "$POSTGRES_PASSWORD"

# MinIO password is fixed to match config/mcp_settings.json
put /lobechat/minio-root-password "minioadmin2026"

# ── Provide these manually ───────────────────────────────────────────────────
# Copy values from infra/config.local before running.

OPENROUTER_API_KEY="REPLACE-WITH-YOUR-OPENROUTER-KEY"
DUCKDNS_TOKEN="REPLACE-WITH-YOUR-DUCKDNS-TOKEN"
GITHUB_TOKEN="REPLACE-WITH-YOUR-GITHUB-TOKEN"

if [[ "$OPENROUTER_API_KEY" == *"REPLACE"* ]] || [[ "$GITHUB_TOKEN" == *"REPLACE"* ]]; then
  echo ""
  echo "ERROR: Fill in OPENROUTER_API_KEY, DUCKDNS_TOKEN, and GITHUB_TOKEN before running."
  exit 1
fi

put /lobechat/openrouter-api-key "$OPENROUTER_API_KEY"
put /lobechat/duckdns-token      "$DUCKDNS_TOKEN"
put /lobechat/github-token       "$GITHUB_TOKEN"

echo ""
echo "=== All secrets stored. You can now deploy with CloudFormation. ==="
