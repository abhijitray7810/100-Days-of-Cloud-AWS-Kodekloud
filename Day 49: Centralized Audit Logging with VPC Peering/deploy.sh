#!/bin/bash
# ============================================================
#  Nautilus DevOps - Log Aggregation Full Deployment Script
#  Run this on the KodeKloud aws-client host as root
# ============================================================

set -euo pipefail

REGION="us-east-1"
PUB_VPC_CIDR="10.1.0.0/16"
PUB_SUBNET_CIDR="10.1.1.0/24"
KEY_NAME="devops-key"
KEY_PATH="/root/.ssh/devops-key.pem"
S3_BUCKET="devops-s3-logs-9737"
IAM_ROLE="devops-s3-role"
S3_LOG_KEY="devops-priv-vpc/boot/boots.log"

# Colors
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log()  { echo -e "${GREEN}  ✓  $1${NC}"; }
warn() { echo -e "${YELLOW}  ⚠  $1${NC}"; }
err()  { echo -e "${RED}  ✗  $1${NC}"; exit 1; }

echo "=========================================================="
echo "  Nautilus DevOps Log Aggregation Setup"
echo "=========================================================="

# ── Step 0: Verify credentials ──────────────────────────────
echo -e "\n[0] Verifying AWS credentials..."
aws sts get-caller-identity --region $REGION || err "Invalid credentials!"
log "Credentials valid"

# ── Step 1: Get private VPC info ────────────────────────────
echo -e "\n[1] Getting private VPC details..."
PRIV_VPC_ID=$(aws ec2 describe-vpcs --region $REGION \
  --filters "Name=tag:Name,Values=devops-priv-vpc" \
  --query "Vpcs[0].VpcId" --output text)
[[ "$PRIV_VPC_ID" == "None" || -z "$PRIV_VPC_ID" ]] && err "devops-priv-vpc not found!"

PRIV_VPC_CIDR=$(aws ec2 describe-vpcs --region $REGION \
  --vpc-ids $PRIV_VPC_ID \
  --query "Vpcs[0].CidrBlock" --output text)

PRIV_SUBNET_ID=$(aws ec2 describe-subnets --region $REGION \
  --filters "Name=tag:Name,Values=devops-priv-subnet" "Name=vpc-id,Values=$PRIV_VPC_ID" \
  --query "Subnets[0].SubnetId" --output text)

PRIV_RT_ID=$(aws ec2 describe-route-tables --region $REGION \
  --filters "Name=tag:Name,Values=devops-priv-rt" "Name=vpc-id,Values=$PRIV_VPC_ID" \
  --query "RouteTables[0].RouteTableId" --output text)

PRIV_EC2_ID=$(aws ec2 describe-instances --region $REGION \
  --filters "Name=tag:Name,Values=devops-priv-ec2" "Name=vpc-id,Values=$PRIV_VPC_ID" \
             "Name=instance-state-name,Values=running,stopped,pending" \
  --query "Reservations[0].Instances[0].InstanceId" --output text)

PRIV_IP=$(aws ec2 describe-instances --region $REGION \
  --instance-ids $PRIV_EC2_ID \
  --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)

log "Private VPC: $PRIV_VPC_ID ($PRIV_VPC_CIDR)"
log "Private Subnet: $PRIV_SUBNET_ID | RT: $PRIV_RT_ID"
log "Private EC2: $PRIV_EC2_ID @ $PRIV_IP"

# ── Step 2: Create public VPC ───────────────────────────────
echo -e "\n[2] Creating public VPC (devops-pub-vpc)..."
PUB_VPC_ID=$(aws ec2 describe-vpcs --region $REGION \
  --filters "Name=tag:Name,Values=devops-pub-vpc" \
  --query "Vpcs[0].VpcId" --output text 2>/dev/null)

if [[ "$PUB_VPC_ID" == "None" || -z "$PUB_VPC_ID" ]]; then
  PUB_VPC_ID=$(aws ec2 create-vpc --region $REGION \
    --cidr-block $PUB_VPC_CIDR \
    --query "Vpc.VpcId" --output text)
  aws ec2 create-tags --region $REGION \
    --resources $PUB_VPC_ID --tags Key=Name,Value=devops-pub-vpc
  aws ec2 modify-vpc-attribute --region $REGION \
    --vpc-id $PUB_VPC_ID --enable-dns-support "{\"Value\":true}"
  aws ec2 modify-vpc-attribute --region $REGION \
    --vpc-id $PUB_VPC_ID --enable-dns-hostnames "{\"Value\":true}"
  log "Created: $PUB_VPC_ID"
else
  warn "Already exists: $PUB_VPC_ID"
fi

# ── Step 3: Create public subnet ───────────────────────────
echo -e "\n[3] Creating public subnet (devops-pub-subnet)..."
PUB_SUBNET_ID=$(aws ec2 describe-subnets --region $REGION \
  --filters "Name=tag:Name,Values=devops-pub-subnet" "Name=vpc-id,Values=$PUB_VPC_ID" \
  --query "Subnets[0].SubnetId" --output text 2>/dev/null)

if [[ "$PUB_SUBNET_ID" == "None" || -z "$PUB_SUBNET_ID" ]]; then
  AZ=$(aws ec2 describe-availability-zones --region $REGION \
    --filters "Name=state,Values=available" \
    --query "AvailabilityZones[0].ZoneName" --output text)
  PUB_SUBNET_ID=$(aws ec2 create-subnet --region $REGION \
    --vpc-id $PUB_VPC_ID --cidr-block $PUB_SUBNET_CIDR \
    --availability-zone $AZ \
    --query "Subnet.SubnetId" --output text)
  aws ec2 create-tags --region $REGION \
    --resources $PUB_SUBNET_ID --tags Key=Name,Value=devops-pub-subnet
  aws ec2 modify-subnet-attribute --region $REGION \
    --subnet-id $PUB_SUBNET_ID --map-public-ip-on-launch
  log "Created: $PUB_SUBNET_ID in $AZ"
else
  warn "Already exists: $PUB_SUBNET_ID"
fi

# ── Step 4: Internet Gateway ───────────────────────────────
echo -e "\n[4] Creating and attaching Internet Gateway..."
IGW_ID=$(aws ec2 describe-internet-gateways --region $REGION \
  --filters "Name=attachment.vpc-id,Values=$PUB_VPC_ID" \
  --query "InternetGateways[0].InternetGatewayId" --output text 2>/dev/null)

if [[ "$IGW_ID" == "None" || -z "$IGW_ID" ]]; then
  IGW_ID=$(aws ec2 create-internet-gateway --region $REGION \
    --query "InternetGateway.InternetGatewayId" --output text)
  aws ec2 create-tags --region $REGION \
    --resources $IGW_ID --tags Key=Name,Value=devops-pub-vpc-igw
  aws ec2 attach-internet-gateway --region $REGION \
    --internet-gateway-id $IGW_ID --vpc-id $PUB_VPC_ID
  log "Created & attached IGW: $IGW_ID"
else
  warn "IGW already attached: $IGW_ID"
fi

# ── Step 5: Public route table ─────────────────────────────
echo -e "\n[5] Creating public route table (devops-pub-rt)..."
PUB_RT_ID=$(aws ec2 describe-route-tables --region $REGION \
  --filters "Name=tag:Name,Values=devops-pub-rt" "Name=vpc-id,Values=$PUB_VPC_ID" \
  --query "RouteTables[0].RouteTableId" --output text 2>/dev/null)

if [[ "$PUB_RT_ID" == "None" || -z "$PUB_RT_ID" ]]; then
  PUB_RT_ID=$(aws ec2 create-route-table --region $REGION \
    --vpc-id $PUB_VPC_ID \
    --query "RouteTable.RouteTableId" --output text)
  aws ec2 create-tags --region $REGION \
    --resources $PUB_RT_ID --tags Key=Name,Value=devops-pub-rt
  log "Created: $PUB_RT_ID"
else
  warn "Already exists: $PUB_RT_ID"
fi

# Add internet route
aws ec2 create-route --region $REGION \
  --route-table-id $PUB_RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID 2>/dev/null && log "Added 0.0.0.0/0 → IGW" || warn "Internet route exists"

# Associate subnet with route table
ASSOC=$(aws ec2 describe-route-tables --region $REGION \
  --route-table-ids $PUB_RT_ID \
  --query "RouteTables[0].Associations[?SubnetId=='$PUB_SUBNET_ID'].RouteTableAssociationId" \
  --output text)
if [[ -z "$ASSOC" || "$ASSOC" == "None" ]]; then
  aws ec2 associate-route-table --region $REGION \
    --route-table-id $PUB_RT_ID --subnet-id $PUB_SUBNET_ID
  log "Associated route table with subnet"
else
  warn "Already associated"
fi

# ── Step 6: Security Group ─────────────────────────────────
echo -e "\n[6] Creating security group for public EC2..."
SG_ID=$(aws ec2 describe-security-groups --region $REGION \
  --filters "Name=group-name,Values=devops-pub-sg" "Name=vpc-id,Values=$PUB_VPC_ID" \
  --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)

if [[ "$SG_ID" == "None" || -z "$SG_ID" ]]; then
  SG_ID=$(aws ec2 create-security-group --region $REGION \
    --group-name devops-pub-sg \
    --description "Public EC2 SG" \
    --vpc-id $PUB_VPC_ID \
    --query "GroupId" --output text)
  aws ec2 create-tags --region $REGION \
    --resources $SG_ID --tags Key=Name,Value=devops-pub-sg
  aws ec2 authorize-security-group-ingress --region $REGION \
    --group-id $SG_ID \
    --ip-permissions \
      "IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=0.0.0.0/0}]" \
      "IpProtocol=-1,IpRanges=[{CidrIp=$PRIV_VPC_CIDR}]"
  log "Created SG: $SG_ID"
else
  warn "Already exists: $SG_ID"
fi

# ── Step 7: IAM Role ───────────────────────────────────────
echo -e "\n[7] Creating IAM role ($IAM_ROLE)..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

TRUST_POLICY='{
  "Version":"2012-10-17",
  "Statement":[{
    "Effect":"Allow",
    "Principal":{"Service":"ec2.amazonaws.com"},
    "Action":"sts:AssumeRole"
  }]
}'

aws iam create-role \
  --role-name $IAM_ROLE \
  --assume-role-policy-document "$TRUST_POLICY" \
  --description "EC2 role for S3 log uploads" \
  2>/dev/null && log "Created role $IAM_ROLE" || warn "Role already exists"

S3_POLICY=$(cat << POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:PutObject","s3:GetObject","s3:ListBucket"],
    "Resource": [
      "arn:aws:s3:::${S3_BUCKET}",
      "arn:aws:s3:::${S3_BUCKET}/*"
    ]
  }]
}
POLICY
)

aws iam put-role-policy \
  --role-name $IAM_ROLE \
  --policy-name devops-s3-put-policy \
  --policy-document "$S3_POLICY"
log "Attached S3 PutObject policy"

aws iam create-instance-profile \
  --instance-profile-name $IAM_ROLE 2>/dev/null && log "Created instance profile" || warn "Profile exists"

aws iam add-role-to-instance-profile \
  --instance-profile-name $IAM_ROLE \
  --role-name $IAM_ROLE 2>/dev/null && log "Added role to profile" || warn "Role already in profile"

echo "  Waiting 15s for IAM propagation..."
sleep 15

# ── Step 8: Launch public EC2 ──────────────────────────────
echo -e "\n[8] Launching public EC2 (devops-pub-ec2)..."
PUB_EC2_ID=$(aws ec2 describe-instances --region $REGION \
  --filters "Name=tag:Name,Values=devops-pub-ec2" \
            "Name=instance-state-name,Values=running,pending,stopped" \
  --query "Reservations[0].Instances[0].InstanceId" --output text 2>/dev/null)

if [[ "$PUB_EC2_ID" == "None" || -z "$PUB_EC2_ID" ]]; then
  # Get latest Ubuntu 22.04 AMI
  AMI_ID=$(aws ec2 describe-images --region $REGION \
    --owners 099720109477 \
    --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
              "Name=state,Values=available" \
              "Name=architecture,Values=x86_64" \
    --query "sort_by(Images,&CreationDate)[-1].ImageId" --output text)
  log "Using AMI: $AMI_ID"

  PUB_EC2_ID=$(aws ec2 run-instances --region $REGION \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --key-name $KEY_NAME \
    --subnet-id $PUB_SUBNET_ID \
    --security-group-ids $SG_ID \
    --associate-public-ip-address \
    --iam-instance-profile Name=$IAM_ROLE \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=devops-pub-ec2}]" \
    --query "Instances[0].InstanceId" --output text)
  log "Launched: $PUB_EC2_ID — waiting for running state..."
  aws ec2 wait instance-running --region $REGION --instance-ids $PUB_EC2_ID
  log "Instance is running"
else
  warn "Already exists: $PUB_EC2_ID"
  # Attach IAM profile if missing
  PROFILE=$(aws ec2 describe-instances --region $REGION --instance-ids $PUB_EC2_ID \
    --query "Reservations[0].Instances[0].IamInstanceProfile.Arn" --output text 2>/dev/null)
  if [[ "$PROFILE" == "None" || -z "$PROFILE" ]]; then
    aws ec2 associate-iam-instance-profile --region $REGION \
      --instance-id $PUB_EC2_ID \
      --iam-instance-profile Name=$IAM_ROLE 2>/dev/null && log "IAM profile attached" || warn "Could not attach profile"
  fi
fi

PUB_IP=$(aws ec2 describe-instances --region $REGION \
  --instance-ids $PUB_EC2_ID \
  --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
log "Public EC2: $PUB_EC2_ID @ $PUB_IP"

# ── Step 9: S3 Bucket ──────────────────────────────────────
echo -e "\n[9] Creating private S3 bucket ($S3_BUCKET)..."
aws s3api create-bucket --bucket $S3_BUCKET --region $REGION 2>/dev/null \
  && log "Created bucket" || warn "Bucket exists"

aws s3api put-public-access-block --bucket $S3_BUCKET \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
log "Blocked public access"

aws s3api put-bucket-versioning --bucket $S3_BUCKET \
  --versioning-configuration Status=Enabled
log "Enabled versioning"

# ── Step 10: VPC Peering ───────────────────────────────────
echo -e "\n[10] Creating VPC Peering (devops-vpc-peering)..."
PCX_ID=$(aws ec2 describe-vpc-peering-connections --region $REGION \
  --filters "Name=tag:Name,Values=devops-vpc-peering" \
            "Name=status-code,Values=active,pending-acceptance" \
  --query "VpcPeeringConnections[0].VpcPeeringConnectionId" --output text 2>/dev/null)

if [[ "$PCX_ID" == "None" || -z "$PCX_ID" ]]; then
  PCX_ID=$(aws ec2 create-vpc-peering-connection --region $REGION \
    --vpc-id $PUB_VPC_ID --peer-vpc-id $PRIV_VPC_ID \
    --query "VpcPeeringConnection.VpcPeeringConnectionId" --output text)
  aws ec2 create-tags --region $REGION \
    --resources $PCX_ID --tags Key=Name,Value=devops-vpc-peering
  sleep 3
  aws ec2 accept-vpc-peering-connection --region $REGION \
    --vpc-peering-connection-id $PCX_ID
  log "Created & accepted: $PCX_ID"
else
  warn "Already exists: $PCX_ID"
fi

# ── Step 11: Update route tables ──────────────────────────
echo -e "\n[11] Adding peering routes..."

# Private RT → Public VPC via peering
aws ec2 create-route --region $REGION \
  --route-table-id $PRIV_RT_ID \
  --destination-cidr-block $PUB_VPC_CIDR \
  --vpc-peering-connection-id $PCX_ID \
  2>/dev/null && log "priv-rt: → $PUB_VPC_CIDR via $PCX_ID" || warn "Route exists in priv-rt"

# Public RT → Private VPC via peering
aws ec2 create-route --region $REGION \
  --route-table-id $PUB_RT_ID \
  --destination-cidr-block $PRIV_VPC_CIDR \
  --vpc-peering-connection-id $PCX_ID \
  2>/dev/null && log "pub-rt: → $PRIV_VPC_CIDR via $PCX_ID" || warn "Route exists in pub-rt"

# ── Step 12: Update private SG ────────────────────────────
echo -e "\n[12] Updating private VPC security groups..."
PRIV_SGS=$(aws ec2 describe-security-groups --region $REGION \
  --filters "Name=vpc-id,Values=$PRIV_VPC_ID" \
  --query "SecurityGroups[*].GroupId" --output text)

for SG in $PRIV_SGS; do
  aws ec2 authorize-security-group-ingress --region $REGION \
    --group-id $SG \
    --ip-permissions "IpProtocol=-1,IpRanges=[{CidrIp=$PUB_VPC_CIDR,Description='From public VPC'}]" \
    2>/dev/null && log "Updated SG $SG" || warn "Rule exists in SG $SG"
done

# ── Step 13: Set up cron jobs ──────────────────────────────
echo -e "\n[13] Configuring cron jobs on EC2 instances..."
echo "  Public IP: $PUB_IP | Private IP: $PRIV_IP"
echo "  Waiting 30s for public EC2 to finish booting..."
sleep 30

# Copy private key to public EC2
echo "  [A] Copying SSH key to public EC2..."
scp -i "$KEY_PATH" -o StrictHostKeyChecking=no -o ConnectTimeout=30 \
  "$KEY_PATH" ubuntu@$PUB_IP:/home/ubuntu/.ssh/devops-key.pem
ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no ubuntu@$PUB_IP \
  "chmod 600 /home/ubuntu/.ssh/devops-key.pem"
log "Key copied to public EC2"

# Configure public EC2 cron
echo "  [B] Setting up cron on public EC2..."
ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no ubuntu@$PUB_IP bash << REMOTE_EOF
set -e

# Ensure AWS CLI is installed
if ! command -v aws &>/dev/null; then
  sudo apt-get update -y -q
  sudo apt-get install -y -q awscli
fi

# Create S3 push script
cat > /home/ubuntu/push_to_s3.sh << 'SCRIPT'
#!/bin/bash
LOCAL="/tmp/boots.log"
BUCKET="${S3_BUCKET}"
S3_KEY="${S3_LOG_KEY}"
REGION="${REGION}"
if [ -f "\$LOCAL" ]; then
  aws s3 cp "\$LOCAL" "s3://\$BUCKET/\$S3_KEY" --region \$REGION
  echo "\$(date): Pushed to s3://\$BUCKET/\$S3_KEY" >> /home/ubuntu/s3_push.log
else
  echo "\$(date): /tmp/boots.log not found" >> /home/ubuntu/s3_push.log
fi
SCRIPT

chmod +x /home/ubuntu/push_to_s3.sh

# Install cron
(crontab -l 2>/dev/null; echo "*/5 * * * * /home/ubuntu/push_to_s3.sh") | sort -u | crontab -
echo "Cron job set on public EC2"
crontab -l
REMOTE_EOF
log "Public EC2 cron configured"

# Configure private EC2 cron via jump through public EC2
echo "  [C] Setting up cron on private EC2 (jump via public EC2)..."
ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no ubuntu@$PUB_IP bash << JUMP_EOF
# Create the setup script for private EC2
cat > /tmp/setup_priv.sh << 'PRIV_SCRIPT'
#!/bin/bash
# Create boots.log if it doesn't exist
if [ ! -f /var/log/boots.log ]; then
  sudo touch /var/log/boots.log
  sudo chmod 644 /var/log/boots.log
  echo "\$(date): Boot log initialized" | sudo tee -a /var/log/boots.log
fi

# Create scp push script
cat > /home/ubuntu/push_log.sh << 'SCRIPT'
#!/bin/bash
SRC="/var/log/boots.log"
DEST_USER="ubuntu"
DEST_HOST="${PUB_IP}"
KEY="/home/ubuntu/.ssh/devops-key.pem"
scp -i "\$KEY" -o StrictHostKeyChecking=no "\$SRC" "\$DEST_USER@\$DEST_HOST:/tmp/boots.log"
echo "\$(date): Pushed boots.log to \$DEST_HOST" >> /home/ubuntu/push_log.log
SCRIPT

chmod +x /home/ubuntu/push_log.sh
(crontab -l 2>/dev/null; echo "*/5 * * * * /home/ubuntu/push_log.sh") | sort -u | crontab -
echo "Cron configured on private EC2"
crontab -l
PRIV_SCRIPT

# SCP and run on private EC2
scp -i /home/ubuntu/.ssh/devops-key.pem -o StrictHostKeyChecking=no \
  /tmp/setup_priv.sh ubuntu@${PRIV_IP}:/tmp/setup_priv.sh
ssh -i /home/ubuntu/.ssh/devops-key.pem -o StrictHostKeyChecking=no \
  ubuntu@${PRIV_IP} "bash /tmp/setup_priv.sh"
JUMP_EOF
log "Private EC2 cron configured"

# ── Final Summary ──────────────────────────────────────────
echo ""
echo "=========================================================="
echo "  DEPLOYMENT COMPLETE!"
echo "=========================================================="
echo "  Private VPC:     $PRIV_VPC_ID ($PRIV_VPC_CIDR)"
echo "  Public  VPC:     $PUB_VPC_ID ($PUB_VPC_CIDR)"
echo "  VPC Peering:     $PCX_ID"
echo "  Public Subnet:   $PUB_SUBNET_ID"
echo "  Public RT:       $PUB_RT_ID"
echo "  Internet GW:     $IGW_ID"
echo "  Public EC2:      $PUB_EC2_ID @ $PUB_IP"
echo "  Private EC2:     $PRIV_EC2_ID @ $PRIV_IP"
echo "  IAM Role:        $IAM_ROLE"
echo "  S3 Bucket:       s3://$S3_BUCKET"
echo "  S3 Log Path:     $S3_LOG_KEY"
echo ""
echo "  Log Flow:"
echo "  $PRIV_IP:/var/log/boots.log"
echo "      ↓  SCP every 5 min (cron)"
echo "  $PUB_IP:/tmp/boots.log"
echo "      ↓  aws s3 cp every 5 min (cron)"
echo "  s3://$S3_BUCKET/$S3_LOG_KEY"
echo "=========================================================="
