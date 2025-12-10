# AWS EBS Volume Creation Guide
![image]()

## Task Overview
Create an EBS volume for Nautilus DevOps team's infrastructure migration to AWS.

## Requirements
- **Volume Name**: datacenter-volume
- **Volume Type**: gp3
- **Volume Size**: 2 GiB
- **Region**: us-east-1

## Steps to Create the Volume

### 1. Configure AWS Credentials
```bash
# On aws-client host, retrieve credentials
showcreds

# Configure AWS CLI
aws configure
# Enter the following when prompted:
# AWS Access Key ID: [from showcreds output]
# AWS Secret Access Key: [from showcreds output]
# Default region name: us-east-1
# Default output format: json
```

### 2. Create the EBS Volume
```bash
# Create volume with required specifications
aws ec2 create-volume \
    --volume-type gp3 \
    --size 2 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=datacenter-volume}]' \
    --region us-east-1
```

### 3. Verify Volume Creation
```bash
# List volumes to confirm creation
aws ec2 describe-volumes \
    --filters "Name=tag:Name,Values=datacenter-volume" \
    --region us-east-1 \
    --query 'Volumes[*].[VolumeId,Size,VolumeType,State,Tags[?Key==`Name`].Value|[0]]' \
    --output table
```

## Alternative: AWS Console Method

1. Login to AWS Console: https://067458473202.signin.aws.amazon.com/console?region=us-east-1
2. Navigate to **EC2** > **Elastic Block Store** > **Volumes**
3. Click **Create Volume**
4. Configure:
   - Volume Type: **gp3**
   - Size: **2** GiB
   - Availability Zone: **us-east-1a** (or any zone in us-east-1)
5. Add Tag: Key=**Name**, Value=**datacenter-volume**
6. Click **Create Volume**

## Access Credentials
- **Console URL**: https://067458473202.signin.aws.amazon.com/console?region=us-east-1
- **Username**: kk_labs_user_975322
- **Password**: mU0@!gyN4@Mt
- **Session Valid**: Wed Dec 10 17:06:34 UTC 2025 - 18:06:34 UTC 2025

## Notes
- All resources must be created in **us-east-1** region
- Volume will be created in available state
- Can be attached to EC2 instances in the same availability zone later
