# Enable EC2 Termination Protection for nautilus-ec2
![image]()


## Overview
This guide explains how to enable termination protection for the `nautilus-ec2` instance in the us-east-1 region.

## Prerequisites
- AWS Console access or AWS CLI configured
- Appropriate IAM permissions to modify EC2 instances
![image]()
## AWS Credentials
- **Console URL**: https://959459115696.signin.aws.amazon.com/console?region=us-east-1
- **Username**: kk_labs_user_482481
- **Password**: XxR!Ajhlc99%
- **Region**: us-east-1

## Method 1: Using AWS CLI

### Step 1: Get the Instance ID
```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=nautilus-ec2" \
  --region us-east-1 \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text
```

### Step 2: Enable Termination Protection
```bash
aws ec2 modify-instance-attribute \
  --instance-id <INSTANCE_ID> \
  --disable-api-termination \
  --region us-east-1
```

### Step 3: Verify Termination Protection
```bash
aws ec2 describe-instance-attribute \
  --instance-id <INSTANCE_ID> \
  --attribute disableApiTermination \
  --region us-east-1
```

## Method 2: Using AWS Console

1. Log in to the AWS Console using the provided credentials
2. Navigate to **EC2 Dashboard** in us-east-1 region
3. Click on **Instances** in the left sidebar
4. Find and select the `nautilus-ec2` instance
5. Click **Actions** → **Instance Settings** → **Change termination protection**
6. Check the **Enable** checkbox
7. Click **Save**

## Verification

After enabling termination protection, verify by checking:
- The instance attribute `DisableApiTermination` should be set to `true`
- Attempting to terminate the instance will show a protection warning

## Notes
- Termination protection prevents accidental instance termination via API/Console
- You must disable protection before terminating the instance
- This does not prevent stopping or rebooting the instance
- Resources must be created/modified only in us-east-1 region
