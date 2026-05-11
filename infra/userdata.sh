#!/bin/bash
# EC2 first-boot setup for LobeChat final project
set -e
exec >> /var/log/userdata.log 2>&1

echo "=== $(date) : Starting LobeChat setup ==="

# ── 1. Install Docker ────────────────────────────────────────────────────────
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

echo "=== Docker installed ==="

# ── 2. Validate secrets injected by CloudFormation ───────────────────────────
# OPENROUTER_API_KEY, DUCKDNS_TOKEN, MINIO_ROOT_PASSWORD are exported by
# the CloudFormation UserData before calling this script.
: "${OPENROUTER_API_KEY:?OPENROUTER_API_KEY not set}"
: "${DUCKDNS_TOKEN:?DUCKDNS_TOKEN not set}"
: "${MINIO_ROOT_PASSWORD:?MINIO_ROOT_PASSWORD not set}"

# Generate random secrets for database and auth
KEY_VAULTS_SECRET=$(openssl rand -base64 32)
NEXT_AUTH_SECRET=$(openssl rand -base64 32)
POSTGRES_PASSWORD=$(openssl rand -hex 16)

echo "=== Secrets ready ==="

# ── 3. Update DuckDNS with current public IP ─────────────────────────────────
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)

curl -s "https://www.duckdns.org/update?domains=kimlaureen&token=${DUCKDNS_TOKEN}&ip=${PUBLIC_IP}"
echo "=== DuckDNS updated: kimlaureen.duckdns.org → $PUBLIC_IP ==="

cat > /etc/cron.d/duckdns << EOF
*/5 * * * * root TOKEN=\$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") && IP=\$(curl -s -H "X-aws-ec2-metadata-token: \$TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4) && curl -s "https://www.duckdns.org/update?domains=kimlaureen&token=${DUCKDNS_TOKEN}&ip=\$IP" > /dev/null
EOF

# ── 4. Write .env file ───────────────────────────────────────────────────────
cd /opt/lobechat-aws

cat > .env << EOF
# Host
HOST_DOMAIN=kimlaureen.duckdns.org
APP_URL=https://kimlaureen.duckdns.org
CASDOOR_URL=https://kimlaureen.duckdns.org:47002
S3_PUBLIC_DOMAIN=https://kimlaureen.duckdns.org:9000
MINIO_CORS_ORIGIN=https://kimlaureen.duckdns.org

# Secrets
KEY_VAULTS_SECRET=${KEY_VAULTS_SECRET}
NEXT_AUTH_SECRET=${NEXT_AUTH_SECRET}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}
OPENROUTER_API_KEY=${OPENROUTER_API_KEY}

# Casdoor OAuth client (from config/init_data.json)
AUTH_CASDOOR_ID=a387a4892ee19b1a2249
AUTH_CASDOOR_SECRET=dbf205949d704de81b0b5b3603174e23fbecc354

# S3
S3_BUCKET=lobe

# AWS
AWS_REGION=eu-west-1
AWS_DEFAULT_REGION=eu-west-1
EOF

echo "=== .env written ==="

# ── 5. Wait for DNS to propagate before Caddy requests TLS cert ──────────────
echo "=== Waiting 30s for DNS propagation... ==="
sleep 30

# ── 6. Start the stack ───────────────────────────────────────────────────────
docker compose up -d --build

echo "=== $(date) : LobeChat setup complete ==="
echo "=== Access at: https://kimlaureen.duckdns.org ==="
