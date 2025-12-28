# AWS NAT Instance Setup for Private Subnet Internet Access

## Task Overview
Enable internet access for a private EC2 instance by setting up a NAT Instance in a public subnet. The private instance will upload test files to an S3 bucket once internet connectivity is established.

## Existing Infrastructure
- **VPC**: `datacenter-priv-vpc`
- **Private Subnet**: `datacenter-priv-subnet`
- **Private EC2 Instance**: `datacenter-priv-ec2` (runs cron job to upload to S3 every minute)
- **S3 Bucket**: `datacenter-nat-23788`
- **Test File**: `datacenter-test.txt` (uploaded when internet access works)
![image]()
## AWS Credentials
- **Console URL**: https://059254148810.signin.aws.amazon.com/console?region=us-east-1
- **Username**: `kk_labs_user_831262`
- **Password**: `cFZ^%G0!9kS9`
- **Region**: `us-east-1`

## Architecture

```
Internet
    |
Internet Gateway (IGW)
    |
Public Subnet (datacenter-pub-subnet)
    |
NAT Instance (datacenter-nat-instance)
    |
Private Subnet (datacenter-priv-subnet)
    |
Private EC2 (datacenter-priv-ec2) --> S3 Bucket (datacenter-nat-23788)
```

## Implementation Steps
![image]()
### Step 1: Gather Existing Infrastructure Information

```bash
# Login to AWS CLI
aws configure
# Use credentials from showcreds command

# Get VPC ID
aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=datacenter-priv-vpc" \
    --query 'Vpcs[0].VpcId' \
    --output text

# Get existing private subnet details
aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=datacenter-priv-subnet" \
    --query 'Subnets[0].[SubnetId,CidrBlock,AvailabilityZone]' \
    --output table

# Get Internet Gateway ID (should already exist)
aws ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=<VPC_ID>" \
    --query 'InternetGateways[0].InternetGatewayId' \
    --output text

# Get private instance details
aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=datacenter-priv-ec2" \
    --query 'Reservations[0].Instances[0].[InstanceId,PrivateIpAddress,SubnetId]' \
    --output table
```

### Step 2: Create Public Subnet
![image]()
**Using AWS Console:**

1. Navigate to **VPC Dashboard** → **Subnets**
2. Click **Create subnet**
3. Configuration:
   - **VPC**: Select `datacenter-priv-vpc`
   - **Subnet name**: `datacenter-pub-subnet`
   - **Availability Zone**: Choose same as private subnet or any available
   - **IPv4 CIDR block**: Choose a non-overlapping CIDR (e.g., if private is 10.0.1.0/24, use 10.0.2.0/24)
4. Click **Create subnet**

**Using AWS CLI:**

```bash
# Replace VPC_ID with actual VPC ID
VPC_ID="vpc-xxxxxxxxx"

# Create public subnet
aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.2.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=datacenter-pub-subnet}]' \
    --region us-east-1

# Save the subnet ID
PUBLIC_SUBNET_ID="subnet-xxxxxxxxx"

# Enable auto-assign public IP
aws ec2 modify-subnet-attribute \
    --subnet-id $PUBLIC_SUBNET_ID \
    --map-public-ip-on-launch \
    --region us-east-1
```

### Step 3: Create or Verify Internet Gateway

```bash
# Check if IGW exists and is attached to VPC
aws ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
    --region us-east-1

# If no IGW exists, create one
aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=datacenter-igw}]' \
    --region us-east-1

# Attach to VPC
IGW_ID="igw-xxxxxxxxx"
aws ec2 attach-internet-gateway \
    --internet-gateway-id $IGW_ID \
    --vpc-id $VPC_ID \
    --region us-east-1
```

### Step 4: Create Route Table for Public Subnet
![image]()
**Using AWS Console:**

1. Navigate to **VPC** → **Route Tables**
2. Click **Create route table**
3. Configuration:
   - **Name**: `datacenter-pub-rt`
   - **VPC**: Select `datacenter-priv-vpc`
4. Click **Create**
5. Select the new route table → **Routes** tab → **Edit routes**
6. Add route:
   - **Destination**: `0.0.0.0/0`
   - **Target**: Select Internet Gateway (datacenter-igw)
7. Go to **Subnet associations** tab → **Edit subnet associations**
8. Select `datacenter-pub-subnet`
9. Click **Save associations**

**Using AWS CLI:**

```bash
# Create public route table
aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=datacenter-pub-rt}]' \
    --region us-east-1

PUBLIC_RT_ID="rtb-xxxxxxxxx"

# Add route to Internet Gateway
aws ec2 create-route \
    --route-table-id $PUBLIC_RT_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID \
    --region us-east-1

# Associate with public subnet
aws ec2 associate-route-table \
    --route-table-id $PUBLIC_RT_ID \
    --subnet-id $PUBLIC_SUBNET_ID \
    --region us-east-1
```

### Step 5: Create Security Group for NAT Instance
![image]()
**Using AWS Console:**

1. Navigate to **EC2** → **Security Groups**
2. Click **Create security group**
3. Configuration:
   - **Name**: `datacenter-nat-sg`
   - **Description**: Security group for NAT instance
   - **VPC**: Select `datacenter-priv-vpc`
4. **Inbound rules**:
   - Type: All Traffic, Source: Private subnet CIDR (e.g., 10.0.1.0/24)
5. **Outbound rules**:
   - Type: All Traffic, Destination: 0.0.0.0/0
6. Click **Create security group**

**Using AWS CLI:**

```bash
# Get private subnet CIDR
PRIVATE_CIDR=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=datacenter-priv-subnet" \
    --query 'Subnets[0].CidrBlock' \
    --output text)

# Create security group
aws ec2 create-security-group \
    --group-name datacenter-nat-sg \
    --description "Security group for NAT instance" \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=datacenter-nat-sg}]' \
    --region us-east-1

NAT_SG_ID="sg-xxxxxxxxx"

# Add inbound rule (allow all from private subnet)
aws ec2 authorize-security-group-ingress \
    --group-id $NAT_SG_ID \
    --protocol -1 \
    --cidr $PRIVATE_CIDR \
    --region us-east-1

# Outbound rules are allowed by default
```

### Step 6: Launch NAT Instance
![image]()
**Using AWS Console:**

1. Navigate to **EC2** → **Instances** → **Launch instances**
2. Configuration:
   - **Name**: `datacenter-nat-instance`
   - **AMI**: Amazon Linux 2 AMI (search for "amzn2-ami-kernel")
   - **Instance type**: `t2.micro` or `t3.micro`
   - **Key pair**: Select existing or create new
   - **Network settings**:
     - VPC: `datacenter-priv-vpc`
     - Subnet: `datacenter-pub-subnet`
     - Auto-assign public IP: Enable
     - Security group: `datacenter-nat-sg`
   - **Advanced details** → **User data**:
     ```bash
     #!/bin/bash
     # Enable IP forwarding
     echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
     sysctl -p /etc/sysctl.conf
     
     # Configure iptables for NAT
     /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
     /sbin/iptables -F FORWARD
     
     # Save iptables rules
     service iptables save
     ```
3. Click **Launch instance**

**Using AWS CLI:**

```bash
# Find Amazon Linux 2 AMI
AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
    --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
    --output text \
    --region us-east-1)

# Create user data script
cat > nat-userdata.sh <<'EOF'
#!/bin/bash
# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

# Configure iptables for NAT
/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
/sbin/iptables -F FORWARD

# Save iptables rules
service iptables save
EOF

# Launch NAT instance
aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --subnet-id $PUBLIC_SUBNET_ID \
    --security-group-ids $NAT_SG_ID \
    --associate-public-ip-address \
    --user-data file://nat-userdata.sh \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=datacenter-nat-instance}]' \
    --region us-east-1

# Get NAT instance ID
NAT_INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=datacenter-nat-instance" \
    --query 'Reservations[0].Instances[0].InstanceId' \
    --output text \
    --region us-east-1)

# Wait for instance to be running
aws ec2 wait instance-running \
    --instance-ids $NAT_INSTANCE_ID \
    --region us-east-1
```

### Step 7: Disable Source/Destination Check

**CRITICAL STEP** - NAT instances must have source/destination check disabled.

**Using AWS Console:**

1. Go to **EC2** → **Instances**
2. Select `datacenter-nat-instance`
3. **Actions** → **Networking** → **Change source/destination check**
4. **Uncheck** "Enable" (or check "Stop")
5. Click **Save**

**Using AWS CLI:**

```bash
# Disable source/destination check
aws ec2 modify-instance-attribute \
    --instance-id $NAT_INSTANCE_ID \
    --no-source-dest-check \
    --region us-east-1
```

### Step 8: Update Private Subnet Route Table

**Using AWS Console:**

1. Navigate to **VPC** → **Route Tables**
2. Find the route table associated with `datacenter-priv-subnet`
3. Select it → **Routes** tab → **Edit routes**
4. **Add route**:
   - **Destination**: `0.0.0.0/0`
   - **Target**: Select **Instance** → Choose `datacenter-nat-instance`
5. Click **Save changes**

**Using AWS CLI:**

```bash
# Get private route table ID
PRIVATE_RT_ID=$(aws ec2 describe-route-tables \
    --filters "Name=association.subnet-id,Values=$(aws ec2 describe-subnets --filters 'Name=tag:Name,Values=datacenter-priv-subnet' --query 'Subnets[0].SubnetId' --output text)" \
    --query 'RouteTables[0].RouteTableId' \
    --output text \
    --region us-east-1)

# Add route to NAT instance
aws ec2 create-route \
    --route-table-id $PRIVATE_RT_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --instance-id $NAT_INSTANCE_ID \
    --region us-east-1
```

### Step 9: Verify Internet Access

**Check S3 Bucket for Test File:**

```bash
# List objects in S3 bucket
aws s3 ls s3://datacenter-nat-23788/

# Wait a few minutes for the cron job to run
# Check again
aws s3 ls s3://datacenter-nat-23788/ | grep datacenter-test.txt

# Download and verify the file
aws s3 cp s3://datacenter-nat-23788/datacenter-test.txt ./
cat datacenter-test.txt
```

**Using AWS Console:**

1. Navigate to **S3**
2. Click on bucket `datacenter-nat-23788`
3. Look for file `datacenter-test.txt`
4. If present, internet access is working!

### Step 10: Additional Verification (Optional)

**Connect to private instance and test:**

```bash
# First, connect to NAT instance (it's in public subnet)
ssh -i your-key.pem ec2-user@<NAT-INSTANCE-PUBLIC-IP>

# From NAT instance, connect to private instance
ssh ec2-user@<PRIVATE-INSTANCE-PRIVATE-IP>

# Test internet connectivity from private instance
ping -c 4 8.8.8.8
curl http://www.google.com
aws s3 ls s3://datacenter-nat-23788/
```

## Complete CLI Script

```bash
#!/bin/bash

# Set variables
REGION="us-east-1"
VPC_NAME="datacenter-priv-vpc"
PRIVATE_SUBNET_NAME="datacenter-priv-subnet"
PUBLIC_SUBNET_NAME="datacenter-pub-subnet"
NAT_INSTANCE_NAME="datacenter-nat-instance"
S3_BUCKET="datacenter-nat-23788"

# Get VPC ID
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=$VPC_NAME" \
    --query 'Vpcs[0].VpcId' \
    --output text \
    --region $REGION)

echo "VPC ID: $VPC_ID"

# Get private subnet details
PRIVATE_SUBNET_ID=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=$PRIVATE_SUBNET_NAME" \
    --query 'Subnets[0].SubnetId' \
    --output text \
    --region $REGION)

PRIVATE_CIDR=$(aws ec2 describe-subnets \
    --subnet-ids $PRIVATE_SUBNET_ID \
    --query 'Subnets[0].CidrBlock' \
    --output text \
    --region $REGION)

echo "Private Subnet ID: $PRIVATE_SUBNET_ID"
echo "Private Subnet CIDR: $PRIVATE_CIDR"

# Determine public subnet CIDR (assuming /24 subnets)
VPC_CIDR=$(aws ec2 describe-vpcs \
    --vpc-ids $VPC_ID \
    --query 'Vpcs[0].CidrBlock' \
    --output text \
    --region $REGION)

# For simplicity, use 10.0.2.0/24 or adjust based on your VPC CIDR
PUBLIC_CIDR="10.0.2.0/24"

# Create public subnet
echo "Creating public subnet..."
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $PUBLIC_CIDR \
    --availability-zone us-east-1a \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$PUBLIC_SUBNET_NAME}]" \
    --query 'Subnet.SubnetId' \
    --output text \
    --region $REGION)

echo "Public Subnet ID: $PUBLIC_SUBNET_ID"

# Enable auto-assign public IP
aws ec2 modify-subnet-attribute \
    --subnet-id $PUBLIC_SUBNET_ID \
    --map-public-ip-on-launch \
    --region $REGION

# Get or create Internet Gateway
IGW_ID=$(aws ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
    --query 'InternetGateways[0].InternetGatewayId' \
    --output text \
    --region $REGION)

if [ "$IGW_ID" == "None" ]; then
    echo "Creating Internet Gateway..."
    IGW_ID=$(aws ec2 create-internet-gateway \
        --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=datacenter-igw}]' \
        --query 'InternetGateway.InternetGatewayId' \
        --output text \
        --region $REGION)
    
    aws ec2 attach-internet-gateway \
        --internet-gateway-id $IGW_ID \
        --vpc-id $VPC_ID \
        --region $REGION
fi

echo "Internet Gateway ID: $IGW_ID"

# Create public route table
echo "Creating public route table..."
PUBLIC_RT_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=datacenter-pub-rt}]' \
    --query 'RouteTable.RouteTableId' \
    --output text \
    --region $REGION)

echo "Public Route Table ID: $PUBLIC_RT_ID"

# Add route to IGW
aws ec2 create-route \
    --route-table-id $PUBLIC_RT_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID \
    --region $REGION

# Associate with public subnet
aws ec2 associate-route-table \
    --route-table-id $PUBLIC_RT_ID \
    --subnet-id $PUBLIC_SUBNET_ID \
    --region $REGION

# Create security group for NAT instance
echo "Creating NAT security group..."
NAT_SG_ID=$(aws ec2 create-security-group \
    --group-name datacenter-nat-sg \
    --description "Security group for NAT instance" \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=datacenter-nat-sg}]' \
    --query 'GroupId' \
    --output text \
    --region $REGION)

echo "NAT Security Group ID: $NAT_SG_ID"

# Add inbound rule
aws ec2 authorize-security-group-ingress \
    --group-id $NAT_SG_ID \
    --protocol -1 \
    --cidr $PRIVATE_CIDR \
    --region $REGION

# Find Amazon Linux 2 AMI
echo "Finding Amazon Linux 2 AMI..."
AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
    --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
    --output text \
    --region $REGION)

echo "AMI ID: $AMI_ID"

# Create user data
cat > /tmp/nat-userdata.sh <<'EOF'
#!/bin/bash
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
/sbin/iptables -F FORWARD
service iptables save
EOF

# Launch NAT instance
echo "Launching NAT instance..."
NAT_INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --subnet-id $PUBLIC_SUBNET_ID \
    --security-group-ids $NAT_SG_ID \
    --associate-public-ip-address \
    --user-data file:///tmp/nat-userdata.sh \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NAT_INSTANCE_NAME}]" \
    --query 'Instances[0].InstanceId' \
    --output text \
    --region $REGION)

echo "NAT Instance ID: $NAT_INSTANCE_ID"

# Wait for instance to be running
echo "Waiting for NAT instance to be running..."
aws ec2 wait instance-running \
    --instance-ids $NAT_INSTANCE_ID \
    --region $REGION

# Disable source/destination check
echo "Disabling source/destination check..."
aws ec2 modify-instance-attribute \
    --instance-id $NAT_INSTANCE_ID \
    --no-source-dest-check \
    --region $REGION

# Get private route table ID
PRIVATE_RT_ID=$(aws ec2 describe-route-tables \
    --filters "Name=association.subnet-id,Values=$PRIVATE_SUBNET_ID" \
    --query 'RouteTables[0].RouteTableId' \
    --output text \
    --region $REGION)

echo "Private Route Table ID: $PRIVATE_RT_ID"

# Add route to NAT instance
echo "Adding route to NAT instance in private route table..."
aws ec2 create-route \
    --route-table-id $PRIVATE_RT_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --instance-id $NAT_INSTANCE_ID \
    --region $REGION

echo "NAT instance setup complete!"
echo "Waiting for cron job to upload test file..."
sleep 120

# Check S3 bucket
echo "Checking S3 bucket for test file..."
aws s3 ls s3://$S3_BUCKET/ | grep datacenter-test.txt

if [ $? -eq 0 ]; then
    echo "SUCCESS! Test file found in S3 bucket."
else
    echo "Test file not yet uploaded. Wait a few more minutes and check again."
fi
```

## Troubleshooting

### Issue: Test file not appearing in S3 bucket

**Checks:**

1. **NAT Instance Source/Destination Check**:
   ```bash
   aws ec2 describe-instance-attribute \
       --instance-id $NAT_INSTANCE_ID \
       --attribute sourceDestCheck \
       --region us-east-1
   ```
   Should return: `"SourceDestCheck": {"Value": false}`

2. **Private Route Table**:
   ```bash
   aws ec2 describe-route-tables \
       --route-table-ids $PRIVATE_RT_ID \
       --region us-east-1
   ```
   Should have route: `0.0.0.0/0` → NAT Instance

3. **NAT Instance User Data**:
   - Connect to NAT instance
   - Check: `cat /var/log/cloud-init-output.log`
   - Verify: `cat /proc/sys/net/ipv4/ip_forward` (should be `1`)
   - Check iptables: `sudo iptables -t nat -L -n -v`

4. **Security Group**:
   - NAT instance SG should allow inbound from private subnet
   - Private instance SG should allow outbound to 0.0.0.0/0

5. **Private Instance IAM Role**:
   - Private instance needs IAM role with S3 permissions
   - Check: `aws sts get-caller-identity` from private instance

6. **Network ACLs**:
   - Check that Network ACLs allow traffic between subnets

### Manual NAT Configuration (if user data fails)

```bash
# SSH to NAT instance
ssh -i your-key.pem ec2-user@<NAT-PUBLIC-IP>

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf

# Configure iptables
sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo /sbin/iptables -F FORWARD

# Save configuration
sudo service iptables save
```

### Check Cron Job on Private Instance

```bash
# SSH to private instance (via NAT instance)
ssh ec2-user@<PRIVATE-IP>

# Check cron job
crontab -l

# Manually test S3 upload
aws s3 cp /tmp/datacenter-test.txt s3://datacenter-nat-23788/

# Check instance metadata for IAM role
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

## Success Criteria

✅ Public subnet `datacenter-pub-subnet` created  
✅ NAT instance `datacenter-nat-instance` running in public subnet  
✅ NAT instance has public IP address  
✅ NAT instance source/destination check disabled  
✅ Custom security group created for NAT instance  
✅ Public route table routes to Internet Gateway  
✅ Private route table routes to NAT instance  
✅ Test file `datacenter-test.txt` appears in S3 bucket `datacenter-nat-23788`  
✅ Private EC2 instance has internet access via NAT instance  

## Cost Considerations

- **NAT Instance**: Running cost of t2.micro/t3.micro instance (~$0.0116/hour)
- **Data Transfer**: Standard AWS data transfer rates apply
- **Cost Savings**: NAT Instance is cheaper than NAT Gateway ($0.045/hour + data processing)

## Cleanup (When No Longer Needed)

```bash
# Delete route from private route table
aws ec2 delete-route \
    --route-table-id $PRIVATE_RT_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --region us-east-1

# Terminate NAT instance
aws ec2 terminate-instances \
    --instance-ids $NAT_INSTANCE_ID \
    --region us-east-1

# Delete security group
aws ec2 delete-security-group \
    --group-id $NAT_SG_ID \
    --region us-east-1

# Disassociate and delete public route table
# Delete public subnet
```

---

**Created for**: Nautilus DevOps Team  
**Region**: us-east-1  
**Date**: December 28, 2025
