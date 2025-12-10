# EC2 Instance Type Change Guide
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/480ec5d166126f36bdfa8dac22bbe7256e398b03/Day%207%3A%20Change%20EC2%20Instance%20Type/Screenshot%202025-12-10%20235735.png)

## Task Overview
Change EC2 instance type from t2.micro to t2.nano for the devops-ec2 instance.

## Requirements
- **Instance Name**: devops-ec2
- **Current Type**: t2.micro
- **New Type**: t2.nano
- **Final State**: running
- **Region**: us-east-1

## Steps to Change Instance Type

### 1. Configure AWS Credentials
```bash
# On aws-client host, retrieve credentials
showcreds

# Configure AWS CLI
aws configure
# Enter credentials from showcreds output
# Default region: us-east-1
# Default output format: json
```

### 2. Get Instance ID
```bash
# Find the devops-ec2 instance
aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=devops-ec2" \
    --region us-east-1 \
    --query 'Reservations[0].Instances[0].[InstanceId,State.Name,InstanceType,StatusChecks]' \
    --output table
```

### 3. Wait for Status Checks (if Initializing)
```bash
# Check status
aws ec2 describe-instance-status \
    --instance-ids <INSTANCE_ID> \
    --region us-east-1

# Wait until status checks complete
aws ec2 wait instance-status-ok \
    --instance-ids <INSTANCE_ID> \
    --region us-east-1
```

### 4. Stop the Instance
```bash
# Stop the instance (required before type change)
aws ec2 stop-instances \
    --instance-ids <INSTANCE_ID> \
    --region us-east-1

# Wait for instance to stop
aws ec2 wait instance-stopped \
    --instance-ids <INSTANCE_ID> \
    --region us-east-1
```

### 5. Change Instance Type
```bash
# Modify instance type to t2.nano
aws ec2 modify-instance-attribute \
    --instance-id <INSTANCE_ID> \
    --instance-type "{\"Value\": \"t2.nano\"}" \
    --region us-east-1
```

### 6. Start the Instance
```bash
# Start the instance
aws ec2 start-instances \
    --instance-ids <INSTANCE_ID> \
    --region us-east-1

# Wait for instance to be running
aws ec2 wait instance-running \
    --instance-ids <INSTANCE_ID> \
    --region us-east-1
```

### 7. Verify the Change
```bash
# Confirm instance type and state
aws ec2 describe-instances \
    --instance-ids <INSTANCE_ID> \
    --region us-east-1 \
    --query 'Reservations[0].Instances[0].[InstanceId,InstanceType,State.Name]' \
    --output table
```

## Complete Script
```bash
# Get instance ID
INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=devops-ec2" \
    --region us-east-1 \
    --query 'Reservations[0].Instances[0].InstanceId' \
    --output text)

echo "Instance ID: $INSTANCE_ID"

# Wait for status checks (if needed)
echo "Waiting for status checks..."
aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID --region us-east-1 || echo "Status checks complete or timeout"

# Stop instance
echo "Stopping instance..."
aws ec2 stop-instances --instance-ids $INSTANCE_ID --region us-east-1
aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID --region us-east-1

# Change instance type
echo "Changing instance type to t2.nano..."
aws ec2 modify-instance-attribute \
    --instance-id $INSTANCE_ID \
    --instance-type "{\"Value\": \"t2.nano\"}" \
    --region us-east-1

# Start instance
echo "Starting instance..."
aws ec2 start-instances --instance-ids $INSTANCE_ID --region us-east-1
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region us-east-1

# Verify
echo "Verification:"
aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --region us-east-1 \
    --query 'Reservations[0].Instances[0].[InstanceId,InstanceType,State.Name]' \
    --output table
```

## AWS Console Method

1. Login to AWS Console: https://480470673558.signin.aws.amazon.com/console?region=us-east-1
2. Navigate to **EC2** > **Instances**
3. Find and select **devops-ec2** instance
4. Wait for **Status checks** to complete (2/2 checks passed)
5. Click **Instance state** > **Stop instance**
6. Wait for instance to stop completely
7. Select the stopped instance
8. Click **Actions** > **Instance settings** > **Change instance type**
9. Select **t2.nano** from dropdown
10. Click **Apply**
11. Click **Instance state** > **Start instance**
12. Verify instance is in **running** state with type **t2.nano**

## Access Credentials
- **Console URL**: https://480470673558.signin.aws.amazon.com/console?region=us-east-1
- **Username**: kk_labs_user_214768
- **Password**: EJQ6ZUPRB^d9
- **Session Valid**: Wed Dec 10 18:18:34 - 19:18:34 UTC 2025

## Important Notes
- Instance must be **stopped** before changing type
- Status checks must be complete before stopping
- All operations must be in **us-east-1** region
- Instance will have brief downtime during the change
- Verify final state is **running** with type **t2.nano**
