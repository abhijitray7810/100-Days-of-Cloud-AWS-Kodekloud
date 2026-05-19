#!/bin/bash
# ============================================================
#  Fix: Copy key to private EC2 & verify full pipeline
# ============================================================
set -euo pipefail

REGION="us-east-1"
KEY_PATH="/root/.ssh/devops-key.pem"
S3_BUCKET="devops-s3-logs-9737"
S3_LOG_KEY="devops-priv-vpc/boot/boots.log"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log()  { echo -e "${GREEN}  ✓  $1${NC}"; }
warn() { echo -e "${YELLOW}  ⚠  $1${NC}"; }
err()  { echo -e "${RED}  ✗  $1${NC}"; exit 1; }

# ── Recover IPs ───────────────────────────────────────────
PRIV_VPC_ID=$(aws ec2 describe-vpcs --region $REGION \
  --filters "Name=tag:Name,Values=devops-priv-vpc" \
  --query "Vpcs[0].VpcId" --output text)
PRIV_IP=$(aws ec2 describe-instances --region $REGION \
  --filters "Name=tag:Name,Values=devops-priv-ec2" \
            "Name=vpc-id,Values=$PRIV_VPC_ID" \
            "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
PUB_IP=$(aws ec2 describe-instances --region $REGION \
  --filters "Name=tag:Name,Values=devops-pub-ec2" \
            "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

echo "Public  EC2: $PUB_IP"
echo "Private EC2: $PRIV_IP"

SSH_PUB="ssh -i $KEY_PATH -o StrictHostKeyChecking=no -o ConnectTimeout=15"
SCP_PUB="scp -i $KEY_PATH -o StrictHostKeyChecking=no"

# ── Fix 1: Copy key to public EC2's ubuntu home ───────────
echo -e "\n[Fix 1] Ensuring key exists on public EC2..."
$SCP_PUB "$KEY_PATH" ubuntu@$PUB_IP:/home/ubuntu/.ssh/devops-key.pem
$SSH_PUB ubuntu@$PUB_IP "chmod 600 /home/ubuntu/.ssh/devops-key.pem && ls -la /home/ubuntu/.ssh/"
log "Key present on public EC2"

# ── Fix 2: Copy key to private EC2 (jump via public) ──────
echo -e "\n[Fix 2] Ensuring key exists on private EC2 (via jump)..."
$SSH_PUB ubuntu@$PUB_IP \
  "scp -i /home/ubuntu/.ssh/devops-key.pem \
       -o StrictHostKeyChecking=no \
       /home/ubuntu/.ssh/devops-key.pem \
       ubuntu@${PRIV_IP}:/home/ubuntu/.ssh/devops-key.pem && \
   ssh -i /home/ubuntu/.ssh/devops-key.pem \
       -o StrictHostKeyChecking=no ubuntu@${PRIV_IP} \
       'chmod 600 /home/ubuntu/.ssh/devops-key.pem && ls -la /home/ubuntu/.ssh/'"
log "Key present on private EC2"

# ── Fix 3: Verify push_log.sh has correct PUB_IP ──────────
echo -e "\n[Fix 3] Verifying push_log.sh on private EC2..."
$SSH_PUB ubuntu@$PUB_IP \
  "ssh -i /home/ubuntu/.ssh/devops-key.pem -o StrictHostKeyChecking=no ubuntu@${PRIV_IP} \
   'cat /home/ubuntu/push_log.sh'"

# ── Fix 4: Ensure boots.log exists on private EC2 ─────────
echo -e "\n[Fix 4] Ensuring /var/log/boots.log exists on private EC2..."
$SSH_PUB ubuntu@$PUB_IP \
  "ssh -i /home/ubuntu/.ssh/devops-key.pem -o StrictHostKeyChecking=no ubuntu@${PRIV_IP} \
   'sudo touch /var/log/boots.log && \
    sudo chmod 644 /var/log/boots.log && \
    [ ! -s /var/log/boots.log ] && \
      (echo \$(date): boot log init | sudo tee /var/log/boots.log; \
       [ -f /var/log/boot.log ] && sudo cat /var/log/boot.log | sudo tee -a /var/log/boots.log || true) || \
      echo already has content; \
    ls -lh /var/log/boots.log'"
log "boots.log ready"

# ── Step A: SCP private → public ──────────────────────────
echo -e "\n[Test A] SCP: private EC2 → public EC2..."
$SSH_PUB ubuntu@$PUB_IP \
  "ssh -i /home/ubuntu/.ssh/devops-key.pem -o StrictHostKeyChecking=no ubuntu@${PRIV_IP} \
   'bash /home/ubuntu/push_log.sh && cat /home/ubuntu/push_log.log | tail -3'"
sleep 3

# Confirm file arrived on public EC2
$SSH_PUB ubuntu@$PUB_IP "ls -lh /tmp/boots.log && head -3 /tmp/boots.log"
log "boots.log arrived on public EC2 at /tmp/boots.log"

# ── Step B: S3 upload public → S3 ─────────────────────────
echo -e "\n[Test B] S3 upload: public EC2 → S3..."
$SSH_PUB ubuntu@$PUB_IP "bash /home/ubuntu/push_to_s3.sh && cat /home/ubuntu/s3_push.log | tail -3"
sleep 5

# ── Verify in S3 ──────────────────────────────────────────
echo -e "\n[Verify] Checking S3..."
aws s3 ls "s3://$S3_BUCKET/$S3_LOG_KEY" --region $REGION && \
  log "FILE CONFIRMED: s3://$S3_BUCKET/$S3_LOG_KEY" || \
  err "File NOT found in S3!"

echo ""
echo "=========================================================="
echo "  Pipeline verified end-to-end!"
echo "  s3://$S3_BUCKET/$S3_LOG_KEY"
echo "  Cron runs every 5 min on both instances."
echo "=========================================================="
