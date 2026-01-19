# EC2 to S3 Access Configuration Guide

This guide demonstrates how to configure an EC2 instance with IAM roles to securely access a private S3 bucket for storing and retrieving data.
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/c00020a5dc77bb4a27c48dceaa8c82ecec2fe34c/Day%2037%3A%20Managing%20EC2%20Access%20with%20S3%20Role-based%20Permissions/Screenshot%202026-01-19%20175722.png)
## Project Overview

Setting up secure communication between an EC2 instance and S3 bucket using IAM roles and policies, following AWS security best practices.

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI installed and configured
- SSH client for connecting to EC2
- Region: `us-east-1`
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/c00020a5dc77bb4a27c48dceaa8c82ecec2fe34c/Day%2037%3A%20Managing%20EC2%20Access%20with%20S3%20Role-based%20Permissions/Screenshot%202026-01-19%20175752.png)
## Architecture

```
EC2 Instance (devops-ec2)
    ↓ (IAM Role attached)
IAM Role (devops-role)
    ↓ (Policy attached)
IAM Policy (S3 Access)
    ↓ (Permissions granted)
S3 Bucket (devops-s3-13723)
```

## Step-by-Step Implementation
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/c00020a5dc77bb4a27c48dceaa8c82ecec2fe34c/Day%2037%3A%20Managing%20EC2%20Access%20with%20S3%20Role-based%20Permissions/Screenshot%202026-01-19%20175017.png)
### Step 1: Setup SSH Keys on aws-client

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Display public key
cat ~/.ssh/id_rsa.pub
```
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/c00020a5dc77bb4a27c48dceaa8c82ecec2fe34c/Day%2037%3A%20Managing%20EC2%20Access%20with%20S3%20Role-based%20Permissions/Screenshot%202026-01-19%20174832.png)
### Step 2: Add Public Key to EC2 Instance

```bash
# SSH into the EC2 instance (use existing credentials)
ssh root@<ec2-instance-public-ip>

# Add the public key to authorized_keys
echo "YOUR_PUBLIC_KEY" >> ~/.ssh/authorized_keys

# Set proper permissions
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh

# Exit and test new SSH connection
exit
ssh -i ~/.ssh/id_rsa root@<ec2-instance-public-ip>
```
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/c00020a5dc77bb4a27c48dceaa8c82ecec2fe34c/Day%2037%3A%20Managing%20EC2%20Access%20with%20S3%20Role-based%20Permissions/Screenshot%202026-01-19%20174721.png)
### Step 3: Create Private S3 Bucket

**Using AWS Console:**
1. Navigate to S3 service
2. Click "Create bucket"
3. Bucket name: `devops-s3-13723`
4. Region: `us-east-1`
5. Block all public access: ✅ Enabled
6. Click "Create bucket"

**Using AWS CLI:**
```bash
# Create the bucket
aws s3 mb s3://devops-s3-13723 --region us-east-1

# Block public access
aws s3api put-public-access-block \
    --bucket devops-s3-13723 \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

### Step 4: Create IAM Policy
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/c00020a5dc77bb4a27c48dceaa8c82ecec2fe34c/Day%2037%3A%20Managing%20EC2%20Access%20with%20S3%20Role-based%20Permissions/Screenshot%202026-01-19%20174503.png)
**Using AWS Console:**
1. Navigate to IAM → Policies
2. Click "Create policy"
3. Select JSON tab and paste:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::devops-s3-13723",
        "arn:aws:s3:::devops-s3-13723/*"
      ]
    }
  ]
}
```

4. Name: `devops-s3-policy`
5. Click "Create policy"

**Using AWS CLI:**
```bash
# Create policy JSON file
cat > devops-s3-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::devops-s3-13723",
        "arn:aws:s3:::devops-s3-13723/*"
      ]
    }
  ]
}
EOF

# Create the policy
aws iam create-policy \
    --policy-name devops-s3-policy \
    --policy-document file://devops-s3-policy.json
```

### Step 5: Create IAM Role
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/c00020a5dc77bb4a27c48dceaa8c82ecec2fe34c/Day%2037%3A%20Managing%20EC2%20Access%20with%20S3%20Role-based%20Permissions/Screenshot%202026-01-19%20175017.png)
**Using AWS Console:**
1. Navigate to IAM → Roles
2. Click "Create role"
3. Select "AWS service" → "EC2"
4. Click "Next"
5. Search and select `devops-s3-policy`
6. Click "Next"
7. Role name: `devops-role`
8. Click "Create role"

**Using AWS CLI:**
```bash
# Create trust policy for EC2
cat > trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create the role
aws iam create-role \
    --role-name devops-role \
    --assume-role-policy-document file://trust-policy.json

# Attach the policy to the role
aws iam attach-role-policy \
    --role-name devops-role \
    --policy-arn arn:aws:iam::591122391004:policy/devops-s3-policy

# Create instance profile
aws iam create-instance-profile \
    --instance-profile-name devops-role-profile

# Add role to instance profile
aws iam add-role-to-instance-profile \
    --instance-profile-name devops-role-profile \
    --role-name devops-role
```

### Step 6: Attach IAM Role to EC2 Instance
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/c00020a5dc77bb4a27c48dceaa8c82ecec2fe34c/Day%2037%3A%20Managing%20EC2%20Access%20with%20S3%20Role-based%20Permissions/Screenshot%202026-01-19%20175151.png)
**Using AWS Console:**
1. Navigate to EC2 → Instances
2. Select `devops-ec2` instance
3. Actions → Security → Modify IAM role
4. Select `devops-role`
5. Click "Update IAM role"

**Using AWS CLI:**
```bash
# Get instance ID
INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=devops-ec2" \
    --query "Reservations[0].Instances[0].InstanceId" \
    --output text)

# Attach the instance profile
aws ec2 associate-iam-instance-profile \
    --instance-id $INSTANCE_ID \
    --iam-instance-profile Name=devops-role-profile
```

### Step 7: Test S3 Access from EC2

```bash
# SSH into the EC2 instance
ssh -i ~/.ssh/id_rsa root@<ec2-instance-public-ip>

# Create a test file
echo "Hello from DevOps EC2!" > testfile.txt

# Upload file to S3
aws s3 cp testfile.txt s3://devops-s3-13723/

# List files in the bucket
aws s3 ls s3://devops-s3-13723/

# Download the file to verify
aws s3 cp s3://devops-s3-13723/testfile.txt downloaded.txt

# Verify content
cat downloaded.txt
```

## Verification Checklist

- ✅ SSH key pair created on aws-client
- ✅ Public key added to EC2 authorized_keys
- ✅ S3 bucket `devops-s3-13723` created (private)
- ✅ IAM policy with S3 permissions created
- ✅ IAM role `devops-role` created
- ✅ Policy attached to role
- ✅ Role attached to EC2 instance
- ✅ File successfully uploaded to S3
- ✅ File successfully listed from S3

## Security Best Practices

1. **Principle of Least Privilege**: IAM policy grants only required S3 permissions
2. **No Hard-coded Credentials**: Using IAM roles instead of access keys
3. **Private Bucket**: All public access blocked
4. **SSH Key Authentication**: More secure than password-based authentication
5. **Instance Profile**: Temporary credentials automatically rotated

## Troubleshooting

### Issue: Cannot upload to S3
```bash
# Check IAM role is attached
aws sts get-caller-identity

# Verify bucket exists
aws s3 ls s3://devops-s3-13723/
```

### Issue: Permission denied
```bash
# Check instance profile
aws ec2 describe-instances --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].IamInstanceProfile"

# Verify policy permissions
aws iam get-policy-version \
    --policy-arn arn:aws:iam::591122391004:policy/devops-s3-policy \
    --version-id v1
```

## Cleanup (Optional)

```bash
# Remove objects from bucket
aws s3 rm s3://devops-s3-13723/ --recursive

# Delete bucket
aws s3 rb s3://devops-s3-13723

# Detach policy from role
aws iam detach-role-policy \
    --role-name devops-role \
    --policy-arn arn:aws:iam::591122391004:policy/devops-s3-policy

# Delete role
aws iam delete-role --role-name devops-role

# Delete policy
aws iam delete-policy \
    --policy-arn arn:aws:iam::591122391004:policy/devops-s3-policy
```

## Resources

- [AWS IAM Roles for EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)
- [S3 Bucket Policies](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-policies.html)
- [AWS CLI S3 Commands](https://docs.aws.amazon.com/cli/latest/reference/s3/)

## Author

Nautilus DevOps Team - xFusionCorp Industries

## Session Details

- **Account**: 591122391004
- **User**: kk_labs_user_843016
- **Region**: us-east-1
- **Session Duration**: 1 hour
