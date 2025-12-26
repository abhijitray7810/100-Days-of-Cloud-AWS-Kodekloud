# AWS VPC Peering Configuration Guide

## Project Overview
This guide demonstrates setting up VPC Peering between a default public VPC and a private VPC to enable communication between EC2 instances in different VPCs.

## Prerequisites
- AWS Account with appropriate permissions
- AWS CLI configured or access to AWS Console
- SSH key pair for EC2 access

## Environment Details

### AWS Credentials
- **Console URL**: https://837384458443.signin.aws.amazon.com/console?region=us-east-1
- **Username**: kk_labs_user_939328
- **Password**: x56vUH^bOq@x
- **Region**: us-east-1
- **Session Duration**: Fri Dec 26 06:36:03 UTC 2025 to Fri Dec 26 07:36:03 UTC 2025

### Existing Resources

#### Public VPC (Default VPC)
- EC2 Instance Name: `nautilus-public-ec2`
- Located in default public subnet
- Publicly accessible

#### Private VPC
- VPC Name: `nautilus-private-vpc`
- CIDR Block: `10.1.0.0/16`
- Subnet Name: `nautilus-private-subnet`
- Subnet CIDR: `10.1.1.0/24`
- EC2 Instance Name: `nautilus-private-ec2`

## Implementation Steps
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/147659c2b7f6dede4e1ea5ff58be93438f999515/Day%2029%3A%20Establishing%20Secure%20Communication%20Between%20Public%20and%20Private%20VPCs%20via%20VPC%20Peering/Screenshot%202025-12-26%20123817.png)
### Step 1: Create VPC Peering Connection

1. Navigate to VPC Console → Peering Connections
2. Click "Create Peering Connection"
3. Configure:
   - **Name**: `nautilus-vpc-peering`
   - **VPC (Requester)**: Select default VPC
   - **VPC (Accepter)**: Select `nautilus-private-vpc`
4. Click "Create Peering Connection"
5. Select the peering connection and click "Actions" → "Accept Request"
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/f32ef2b73e3ad46a87beb2b3b272665f4c75aad9/Day%2029%3A%20Establishing%20Secure%20Communication%20Between%20Public%20and%20Private%20VPCs%20via%20VPC%20Peering/Screenshot%202025-12-26%20123833.png)
**AWS CLI Commands:**
```bash
# Get VPC IDs
DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query 'Vpcs[0].VpcId' --output text --region us-east-1)
PRIVATE_VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=nautilus-private-vpc" --query 'Vpcs[0].VpcId' --output text --region us-east-1)

# Create peering connection
PEERING_ID=$(aws ec2 create-vpc-peering-connection \
    --vpc-id $DEFAULT_VPC_ID \
    --peer-vpc-id $PRIVATE_VPC_ID \
    --tag-specifications 'ResourceType=vpc-peering-connection,Tags=[{Key=Name,Value=nautilus-vpc-peering}]' \
    --region us-east-1 \
    --query 'VpcPeeringConnection.VpcPeeringConnectionId' \
    --output text)

# Accept peering connection
aws ec2 accept-vpc-peering-connection \
    --vpc-peering-connection-id $PEERING_ID \
    --region us-east-1
```

### Step 2: Configure Route Tables
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/daf30d34b64298499df30343ec0ddadb88aeb9cd/Day%2029%3A%20Establishing%20Secure%20Communication%20Between%20Public%20and%20Private%20VPCs%20via%20VPC%20Peering/Screenshot%202025-12-26%20123851.png)
#### For Default VPC Route Table

1. Navigate to VPC Console → Route Tables
2. Find the route table associated with the default VPC
3. Click "Routes" tab → "Edit routes"
4. Add route:
   - **Destination**: `10.1.0.0/16` (Private VPC CIDR)
   - **Target**: Select the peering connection `nautilus-vpc-peering`
5. Save changes

**AWS CLI Command:**
```bash
# Get default VPC route table
DEFAULT_RT_ID=$(aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=$DEFAULT_VPC_ID" \
    --query 'RouteTables[0].RouteTableId' \
    --output text \
    --region us-east-1)

# Add route to private VPC
aws ec2 create-route \
    --route-table-id $DEFAULT_RT_ID \
    --destination-cidr-block 10.1.0.0/16 \
    --vpc-peering-connection-id $PEERING_ID \
    --region us-east-1
```

#### For Private VPC Route Table

1. Find the route table associated with `nautilus-private-subnet`
2. Click "Routes" tab → "Edit routes"
3. Add route:
   - **Destination**: Default VPC CIDR (typically `172.31.0.0/16`)
   - **Target**: Select the peering connection `nautilus-vpc-peering`
4. Save changes

**AWS CLI Command:**
```bash
# Get private VPC route table
PRIVATE_RT_ID=$(aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=$PRIVATE_VPC_ID" \
    --query 'RouteTables[0].RouteTableId' \
    --output text \
    --region us-east-1)

# Get default VPC CIDR
DEFAULT_VPC_CIDR=$(aws ec2 describe-vpcs \
    --vpc-ids $DEFAULT_VPC_ID \
    --query 'Vpcs[0].CidrBlock' \
    --output text \
    --region us-east-1)

# Add route to default VPC
aws ec2 create-route \
    --route-table-id $PRIVATE_RT_ID \
    --destination-cidr-block $DEFAULT_VPC_CIDR \
    --vpc-peering-connection-id $PEERING_ID \
    --region us-east-1
```

### Step 3: Configure Security Groups
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/a3e34bcf9ec88279da481c4d26cc5f34e1cb645c/Day%2029%3A%20Establishing%20Secure%20Communication%20Between%20Public%20and%20Private%20VPCs%20via%20VPC%20Peering/Screenshot%202025-12-26%20123908.png)
#### Update Private EC2 Security Group

1. Navigate to EC2 Console → Security Groups
2. Find the security group attached to `nautilus-private-ec2`
3. Add inbound rule:
   - **Type**: All ICMP - IPv4
   - **Source**: Default VPC CIDR (e.g., `172.31.0.0/16`)
4. Save rules

**AWS CLI Command:**
```bash
# Get private EC2 security group
PRIVATE_SG_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=nautilus-private-ec2" \
    --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' \
    --output text \
    --region us-east-1)

# Add ICMP rule
aws ec2 authorize-security-group-ingress \
    --group-id $PRIVATE_SG_ID \
    --protocol icmp \
    --port -1 \
    --cidr $DEFAULT_VPC_CIDR \
    --region us-east-1
```

### Step 4: Add SSH Public Key to Public EC2 Instance

1. From the `aws-client` host, get your public key:
```bash
cat /root/.ssh/id_rsa.pub
```

2. Connect to `nautilus-public-ec2` using AWS Systems Manager Session Manager or EC2 Instance Connect

3. Add the public key to authorized_keys:
```bash
# On the public EC2 instance
echo "YOUR_PUBLIC_KEY_CONTENT" >> /home/ec2-user/.ssh/authorized_keys
chmod 600 /home/ec2-user/.ssh/authorized_keys
```

**Alternative - Using AWS CLI:**
```bash
# Get public EC2 instance ID
PUBLIC_INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=nautilus-public-ec2" \
    --query 'Reservations[0].Instances[0].InstanceId' \
    --output text \
    --region us-east-1)

# Use EC2 Instance Connect to send SSH key
PUBLIC_KEY=$(cat /root/.ssh/id_rsa.pub)
aws ec2-instance-connect send-ssh-public-key \
    --instance-id $PUBLIC_INSTANCE_ID \
    --availability-zone us-east-1a \
    --instance-os-user ec2-user \
    --ssh-public-key "$PUBLIC_KEY" \
    --region us-east-1
```

### Step 5: Test the Connection

1. SSH into the public EC2 instance from aws-client:
```bash
# Get public EC2 IP
PUBLIC_IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=nautilus-public-ec2" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text \
    --region us-east-1)

# SSH into public instance
ssh -i /root/.ssh/id_rsa ec2-user@$PUBLIC_IP
```

2. From the public EC2 instance, ping the private EC2 instance:
```bash
# Get private EC2 IP (run this on aws-client first)
PRIVATE_IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=nautilus-private-ec2" \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text \
    --region us-east-1)

echo "Private EC2 IP: $PRIVATE_IP"

# Then on public EC2 instance
ping -c 4 <PRIVATE_IP>
```

## Verification Checklist

- [ ] VPC Peering connection `nautilus-vpc-peering` created and accepted
- [ ] Route added in default VPC route table pointing to private VPC CIDR
- [ ] Route added in private VPC route table pointing to default VPC CIDR
- [ ] Security group of private EC2 allows ICMP from default VPC CIDR
- [ ] SSH public key added to public EC2 instance
- [ ] Successfully SSH'd into public EC2 instance
- [ ] Successfully pinged private EC2 instance from public EC2 instance

## Troubleshooting

### Cannot SSH into Public EC2
- Verify security group allows SSH (port 22) from your IP
- Verify public key is correctly added to `~/.ssh/authorized_keys`
- Check network ACLs on the subnet

### Cannot Ping Private EC2
- Verify peering connection is in "Active" state
- Check route tables have correct routes
- Verify security group allows ICMP from default VPC CIDR
- Confirm both instances are running

### Peering Connection Issues
- Ensure VPC CIDR blocks don't overlap
- Verify peering connection is accepted
- Check that routes reference the correct peering connection ID

## Network Diagram

```
┌─────────────────────────────────────────────┐
│         Default VPC (172.31.0.0/16)         │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │    nautilus-public-ec2              │   │
│  │    (Public Subnet)                  │   │
│  │    Public IP: X.X.X.X               │   │
│  └─────────────────────────────────────┘   │
│                    │                        │
└────────────────────┼────────────────────────┘
                     │
              VPC Peering
         (nautilus-vpc-peering)
                     │
┌────────────────────┼────────────────────────┐
│                    │                        │
│  ┌─────────────────────────────────────┐   │
│  │    nautilus-private-ec2             │   │
│  │    (Private Subnet: 10.1.1.0/24)    │   │
│  │    Private IP: 10.1.1.X             │   │
│  └─────────────────────────────────────┘   │
│                                             │
│     Private VPC (10.1.0.0/16)              │
│     nautilus-private-vpc                   │
└─────────────────────────────────────────────┘
```

## Complete Script

Here's a complete script to automate the entire setup:

```bash
#!/bin/bash

# Set region
REGION="us-east-1"

echo "=== Starting VPC Peering Configuration ==="

# Get VPC IDs
echo "Getting VPC IDs..."
DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query 'Vpcs[0].VpcId' --output text --region $REGION)
PRIVATE_VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=nautilus-private-vpc" --query 'Vpcs[0].VpcId' --output text --region $REGION)

echo "Default VPC ID: $DEFAULT_VPC_ID"
echo "Private VPC ID: $PRIVATE_VPC_ID"

# Create VPC Peering Connection
echo "Creating VPC Peering Connection..."
PEERING_ID=$(aws ec2 create-vpc-peering-connection \
    --vpc-id $DEFAULT_VPC_ID \
    --peer-vpc-id $PRIVATE_VPC_ID \
    --tag-specifications 'ResourceType=vpc-peering-connection,Tags=[{Key=Name,Value=nautilus-vpc-peering}]' \
    --region $REGION \
    --query 'VpcPeeringConnection.VpcPeeringConnectionId' \
    --output text)

echo "Peering Connection ID: $PEERING_ID"

# Accept VPC Peering Connection
echo "Accepting VPC Peering Connection..."
aws ec2 accept-vpc-peering-connection \
    --vpc-peering-connection-id $PEERING_ID \
    --region $REGION

# Get VPC CIDRs
DEFAULT_VPC_CIDR=$(aws ec2 describe-vpcs --vpc-ids $DEFAULT_VPC_ID --query 'Vpcs[0].CidrBlock' --output text --region $REGION)
echo "Default VPC CIDR: $DEFAULT_VPC_CIDR"

# Configure Route Tables
echo "Configuring route tables..."

# Default VPC Route Table
DEFAULT_RT_ID=$(aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=$DEFAULT_VPC_ID" \
    --query 'RouteTables[0].RouteTableId' \
    --output text \
    --region $REGION)

aws ec2 create-route \
    --route-table-id $DEFAULT_RT_ID \
    --destination-cidr-block 10.1.0.0/16 \
    --vpc-peering-connection-id $PEERING_ID \
    --region $REGION

echo "Route added to default VPC route table"

# Private VPC Route Table
PRIVATE_RT_ID=$(aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=$PRIVATE_VPC_ID" \
    --query 'RouteTables[0].RouteTableId' \
    --output text \
    --region $REGION)

aws ec2 create-route \
    --route-table-id $PRIVATE_RT_ID \
    --destination-cidr-block $DEFAULT_VPC_CIDR \
    --vpc-peering-connection-id $PEERING_ID \
    --region $REGION

echo "Route added to private VPC route table"

# Update Security Group
echo "Updating security group for private EC2..."
PRIVATE_SG_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=nautilus-private-ec2" \
    --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' \
    --output text \
    --region $REGION)

aws ec2 authorize-security-group-ingress \
    --group-id $PRIVATE_SG_ID \
    --protocol icmp \
    --port -1 \
    --cidr $DEFAULT_VPC_CIDR \
    --region $REGION 2>/dev/null

echo "Security group updated"

# Get Instance IPs
PUBLIC_IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=nautilus-public-ec2" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text \
    --region $REGION)

PRIVATE_IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=nautilus-private-ec2" \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text \
    --region $REGION)

echo ""
echo "=== Configuration Complete ==="
echo "Public EC2 IP: $PUBLIC_IP"
echo "Private EC2 IP: $PRIVATE_IP"
echo ""
echo "Next steps:"
echo "1. Add your SSH public key to the public EC2 instance"
echo "2. SSH to public instance: ssh -i /root/.ssh/id_rsa ec2-user@$PUBLIC_IP"
echo "3. Ping private instance: ping $PRIVATE_IP"
```

## Clean Up (Optional)

To remove the VPC peering configuration:

```bash
# Delete routes
aws ec2 delete-route --route-table-id $DEFAULT_RT_ID --destination-cidr-block 10.1.0.0/16 --region us-east-1
aws ec2 delete-route --route-table-id $PRIVATE_RT_ID --destination-cidr-block $DEFAULT_VPC_CIDR --region us-east-1

# Delete VPC peering connection
aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id $PEERING_ID --region us-east-1
```

## Additional Resources

- [AWS VPC Peering Documentation](https://docs.aws.amazon.com/vpc/latest/peering/)
- [VPC Peering Scenarios](https://docs.aws.amazon.com/vpc/latest/peering/peering-scenarios.html)
- [Working with Route Tables](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html)

## Notes

- All resources must be created in `us-east-1` region
- VPC peering is not transitive - if you have VPC A peered with B, and B peered with C, A cannot communicate with C through B
- Overlapping CIDR blocks cannot be peered
- Session expires at Fri Dec 26 07:36:03 UTC 2025
