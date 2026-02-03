# AWS NAT Gateway Setup for Private EC2 Instance
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/dc858c5f472f02cacadb0a58e092ed250ac86580/Day%2045%3A%20Configure%20NAT%20Gateway%20for%20Internet%20Access%20in%20a%20Private%20VPC/Screenshot%202026-02-03%20194232.png)
## Project Overview

This project demonstrates how to enable internet access for an EC2 instance running in a private subnet using a NAT Gateway. The instance will upload a test file to a public S3 bucket once internet connectivity is established.

## Architecture

```
Internet
    ↓
Internet Gateway
    ↓
Public Subnet (datacenter-pub-subnet)
    ↓
NAT Gateway (datacenter-natgw)
    ↓
Private Subnet (datacenter-priv-subnet)
    ↓
EC2 Instance (datacenter-priv-ec2)
    ↓
S3 Bucket (datacenter-nat-10665)
```

## Prerequisites
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/dc858c5f472f02cacadb0a58e092ed250ac86580/Day%2045%3A%20Configure%20NAT%20Gateway%20for%20Internet%20Access%20in%20a%20Private%20VPC/Screenshot%202026-02-03%20194323.png)
### Existing Resources
- **VPC**: `datacenter-priv-vpc`
- **Private Subnet**: `datacenter-priv-subnet`
- **EC2 Instance**: `datacenter-priv-ec2` (running in private subnet)
- **S3 Bucket**: `datacenter-nat-10665` (target for test file upload)
- **Cron Job**: Configured on EC2 instance to upload test file once internet is available

### AWS Credentials
- **Region**: `us-east-1`
- **Console URL**: https://605508872290.signin.aws.amazon.com/console?region=us-east-1
- **Username**: kk_labs_user_655083
- **Password**: lb@ek7T@!6CI

## Implementation Steps
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/dc858c5f472f02cacadb0a58e092ed250ac86580/Day%2045%3A%20Configure%20NAT%20Gateway%20for%20Internet%20Access%20in%20a%20Private%20VPC/Screenshot%202026-02-03%20194339.png)
### 1. Create Public Subnet

Create a public subnet in the same VPC to host the NAT Gateway:

```bash
# Get VPC ID
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=datacenter-priv-vpc" \
  --query 'Vpcs[0].VpcId' \
  --output text \
  --region us-east-1)

# Create public subnet
aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block <CIDR_BLOCK> \
  --availability-zone us-east-1a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=datacenter-pub-subnet}]' \
  --region us-east-1
```

### 2. Create Internet Gateway

Create an Internet Gateway and attach it to the VPC:

```bash
# Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=datacenter-igw}]' \
  --query 'InternetGateway.InternetGatewayId' \
  --output text \
  --region us-east-1)

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID \
  --region us-east-1
```

### 3. Create and Configure Public Route Table

Create a route table for the public subnet and add a route to the Internet Gateway:

```bash
# Create route table
RT_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=datacenter-pub-rt}]' \
  --query 'RouteTable.RouteTableId' \
  --output text \
  --region us-east-1)

# Create route to Internet Gateway
aws ec2 create-route \
  --route-table-id $RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID \
  --region us-east-1

# Associate route table with public subnet
aws ec2 associate-route-table \
  --route-table-id $RT_ID \
  --subnet-id $PUB_SUBNET_ID \
  --region us-east-1
```

### 4. Create NAT Gateway

Allocate an Elastic IP and create the NAT Gateway:

```bash
# Allocate Elastic IP
ALLOC_ID=$(aws ec2 allocate-address \
  --domain vpc \
  --query 'AllocationId' \
  --output text \
  --region us-east-1)

# Create NAT Gateway
NAT_GW_ID=$(aws ec2 create-nat-gateway \
  --subnet-id $PUB_SUBNET_ID \
  --allocation-id $ALLOC_ID \
  --tag-specifications 'ResourceType=natgateway,Tags=[{Key=Name,Value=datacenter-natgw}]' \
  --query 'NatGateway.NatGatewayId' \
  --output text \
  --region us-east-1)

# Wait for NAT Gateway to become available
aws ec2 wait nat-gateway-available \
  --nat-gateway-ids $NAT_GW_ID \
  --region us-east-1
```

### 5. Update Private Route Table

Update the private subnet's route table to route internet traffic through the NAT Gateway:

```bash
# Get private route table ID
PRIV_RT_ID=$(aws ec2 describe-route-tables \
  --filters "Name=vpc-id,Values=$VPC_ID" \
            "Name=association.subnet-id,Values=$PRIV_SUBNET_ID" \
  --query 'RouteTables[0].RouteTableId' \
  --output text \
  --region us-east-1)

# Add route to NAT Gateway
aws ec2 create-route \
  --route-table-id $PRIV_RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --nat-gateway-id $NAT_GW_ID \
  --region us-east-1
```

### 6. Verify Internet Connectivity

Wait 2-3 minutes for the cron job to execute, then verify the test file exists in the S3 bucket:

```bash
# List files in S3 bucket
aws s3 ls s3://datacenter-nat-10665/ --region us-east-1

# Download and verify the test file (optional)
aws s3 cp s3://datacenter-nat-10665/test-file.txt . --region us-east-1
```

## Key Concepts
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/dc858c5f472f02cacadb0a58e092ed250ac86580/Day%2045%3A%20Configure%20NAT%20Gateway%20for%20Internet%20Access%20in%20a%20Private%20VPC/Screenshot%202026-02-03%20194357.png)
### NAT Gateway
- **Purpose**: Allows instances in private subnets to connect to the internet while preventing inbound connections from the internet
- **Location**: Must be deployed in a public subnet
- **Requirements**: Requires an Elastic IP address
- **High Availability**: Create NAT Gateways in multiple AZs for production workloads

### Internet Gateway
- **Purpose**: Allows communication between instances in VPC and the internet
- **Attachment**: One Internet Gateway per VPC
- **Route**: Requires a route in the route table pointing to 0.0.0.0/0

### Route Tables
- **Public Route Table**: Contains route to Internet Gateway (0.0.0.0/0 → IGW)
- **Private Route Table**: Contains route to NAT Gateway (0.0.0.0/0 → NAT-GW)

## Network Flow

1. **Outbound Request**: EC2 instance → Private subnet → NAT Gateway → Internet Gateway → Internet
2. **Response**: Internet → Internet Gateway → NAT Gateway → Private subnet → EC2 instance

## Troubleshooting
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/dc858c5f472f02cacadb0a58e092ed250ac86580/Day%2045%3A%20Configure%20NAT%20Gateway%20for%20Internet%20Access%20in%20a%20Private%20VPC/Screenshot%202026-02-03%20194421.png)
### EC2 Instance Cannot Access Internet

1. **Check NAT Gateway Status**:
   ```bash
   aws ec2 describe-nat-gateways \
     --nat-gateway-ids $NAT_GW_ID \
     --region us-east-1
   ```
   Status should be "available"

2. **Verify Route Table Configuration**:
   ```bash
   aws ec2 describe-route-tables \
     --route-table-ids $PRIV_RT_ID \
     --region us-east-1
   ```
   Should contain a route: 0.0.0.0/0 → NAT Gateway

3. **Check Security Groups**:
   - Ensure EC2 security group allows outbound traffic
   - NAT Gateway doesn't have security groups (uses NACLs)

4. **Verify Network ACLs**:
   - Ensure subnet NACLs allow inbound and outbound traffic

### Test File Not Appearing in S3 Bucket

1. **Wait Longer**: Cron job may take 2-3 minutes to execute
2. **Check EC2 Instance Logs**: SSH to instance (via bastion) and check cron logs
3. **Verify IAM Role**: EC2 instance needs permissions to write to S3 bucket

## Security Best Practices

1. **Least Privilege**: EC2 IAM role should only have S3 PutObject permission for specific bucket
2. **Network Segmentation**: Keep databases and sensitive services in private subnets
3. **Monitoring**: Enable VPC Flow Logs to monitor network traffic
4. **NAT Gateway Redundancy**: Deploy NAT Gateways in multiple AZs for production
5. **Security Groups**: Configure restrictive security group rules
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/dc858c5f472f02cacadb0a58e092ed250ac86580/Day%2045%3A%20Configure%20NAT%20Gateway%20for%20Internet%20Access%20in%20a%20Private%20VPC/Screenshot%202026-02-03%20194508.png)
## Cost Considerations

- **NAT Gateway**: Charged per hour and per GB of data processed
- **Elastic IP**: Free when associated with running instance, charged when not in use
- **Data Transfer**: Outbound data transfer charges apply
- **Alternative**: NAT Instance (cheaper but requires management)

## Cleanup (After Testing)

To avoid ongoing charges, delete resources in this order:

```bash
# Delete route from private route table
aws ec2 delete-route \
  --route-table-id $PRIV_RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --region us-east-1

# Delete NAT Gateway
aws ec2 delete-nat-gateway \
  --nat-gateway-id $NAT_GW_ID \
  --region us-east-1

# Wait for NAT Gateway deletion
aws ec2 wait nat-gateway-deleted \
  --nat-gateway-ids $NAT_GW_ID \
  --region us-east-1

# Release Elastic IP
aws ec2 release-address \
  --allocation-id $ALLOC_ID \
  --region us-east-1

# Delete Internet Gateway
aws ec2 detach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID \
  --region us-east-1

aws ec2 delete-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --region us-east-1

# Delete route table
aws ec2 delete-route-table \
  --route-table-id $RT_ID \
  --region us-east-1

# Delete public subnet
aws ec2 delete-subnet \
  --subnet-id $PUB_SUBNET_ID \
  --region us-east-1
```
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/dc858c5f472f02cacadb0a58e092ed250ac86580/Day%2045%3A%20Configure%20NAT%20Gateway%20for%20Internet%20Access%20in%20a%20Private%20VPC/Screenshot%202026-02-03%20194441.png)
## References

- [AWS NAT Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
- [VPC Routing](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html)
- [Internet Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html)
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/dc858c5f472f02cacadb0a58e092ed250ac86580/Day%2045%3A%20Configure%20NAT%20Gateway%20for%20Internet%20Access%20in%20a%20Private%20VPC/Screenshot%202026-02-03%20194500.png)
## Timeline

- **Start Time**: Tue Feb 03 13:39:22 UTC 2026
- **End Time**: Tue Feb 03 13:39:22 UTC 2026
- **Test File Appearance**: 2-3 minutes after NAT Gateway configuration

## Success Criteria

✅ Public subnet created in VPC  
✅ Internet Gateway created and attached  
✅ Public route table configured with IGW route  
✅ NAT Gateway created with Elastic IP  
✅ Private route table updated with NAT Gateway route  
✅ Test file appears in S3 bucket `datacenter-nat-10665`

---

**Project**: Nautilus DevOps - NAT Gateway Setup  
**Region**: us-east-1  
**Status**: Completed
