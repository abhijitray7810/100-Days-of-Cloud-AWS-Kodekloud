# AWS ENI Attachment Task - README
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/b730e566530210f8cd5dda0dcaa284ca629ca05e/Day%2011%3A%20Attach%20Elastic%20Network%20Interface%20to%20EC2%20Instance/Screenshot%202025-12-12%20211558.png)
## Overview
This guide provides step-by-step instructions for attaching an Elastic Network Interface (ENI) to an EC2 instance in the AWS us-east-1 region.

## Task Requirements
- **Instance Name**: `xfusion-ec2`
- **ENI Name**: `xfusion-eni`
- **Region**: `us-east-1`
- **Goal**: Attach the ENI to the EC2 instance with status `attached`

## Prerequisites
- AWS credentials provided (available via `showcreds` command)
- Access to AWS Console or AWS CLI
- Instance initialization must be completed before submission
![image]()
## AWS Credentials
```
Console URL: https://584135479676.signin.aws.amazon.com/console?region=us-east-1
Username: kk_labs_user_824754
Password: CYKFf8J1uCM3
Region: us-east-1
```

**Session Window**:
- Start Time: Fri Dec 12 15:34:08 UTC 2025
- End Time: Fri Dec 12 16:34:08 UTC 2025

---

## Method 1: Using AWS Console (GUI)

### Step 1: Login to AWS Console
1. Navigate to the Console URL
2. Enter the provided username and password
3. Ensure you're in the **us-east-1** region (check top-right corner)

### Step 2: Locate the ENI
1. Go to **Services** → **EC2**
2. In the left sidebar, scroll down to **Network & Security** → **Network Interfaces**
3. Find the ENI named `xfusion-eni`
4. Note the **Network Interface ID** (format: `eni-xxxxxxxxx`)

### Step 3: Locate the EC2 Instance
1. In the left sidebar, click **Instances**
2. Find the instance named `xfusion-ec2`
3. Verify the instance is in **running** state
4. Note the **Instance ID** (format: `i-xxxxxxxxx`)

### Step 4: Attach the ENI
1. Go back to **Network Interfaces**
2. Select the `xfusion-eni` interface (checkbox)
3. Click **Actions** dropdown → **Attach**
4. In the Attach Network Interface dialog:
   - **Instance**: Select `xfusion-ec2` from the dropdown
   - **Device index**: Leave as default (usually 1 if eth0 is primary)
5. Click **Attach**

### Step 5: Verify Attachment
1. Refresh the Network Interfaces page
2. Check the **Status** column for `xfusion-eni` - it should show **in-use**
3. Click on the ENI to view details
4. Under the **Details** tab, verify:
   - **Status**: `in-use`
   - **Attachment status**: `attached`
   - **Instance ID**: Should match `xfusion-ec2`

---

## Method 2: Using AWS CLI

### Step 1: Configure AWS CLI
```bash
# On aws-client host, retrieve credentials
showcreds

# Configure AWS CLI (if not already configured)
aws configure
# Enter Access Key ID
# Enter Secret Access Key
# Default region: us-east-1
# Default output format: json
```

### Step 2: Get the ENI ID
```bash
# List all ENIs and find xfusion-eni
aws ec2 describe-network-interfaces \
  --region us-east-1 \
  --filters "Name=tag:Name,Values=xfusion-eni" \
  --query 'NetworkInterfaces[0].NetworkInterfaceId' \
  --output text
```

**Example Output**: `eni-0123456789abcdef0`

### Step 3: Get the Instance ID
```bash
# List all instances and find xfusion-ec2
aws ec2 describe-instances \
  --region us-east-1 \
  --filters "Name=tag:Name,Values=xfusion-ec2" "Name=instance-state-name,Values=running" \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text
```

**Example Output**: `i-0123456789abcdef0`

### Step 4: Attach the ENI to Instance
```bash
# Replace <ENI-ID> and <INSTANCE-ID> with actual values
aws ec2 attach-network-interface \
  --region us-east-1 \
  --network-interface-id <ENI-ID> \
  --instance-id <INSTANCE-ID> \
  --device-index 1
```

**Example**:
```bash
aws ec2 attach-network-interface \
  --region us-east-1 \
  --network-interface-id eni-0123456789abcdef0 \
  --instance-id i-0123456789abcdef0 \
  --device-index 1
```

**Expected Output**:
```json
{
    "AttachmentId": "eni-attach-xxxxxxxxx"
}
```

### Step 5: Verify Attachment Status
```bash
# Check ENI attachment status
aws ec2 describe-network-interfaces \
  --region us-east-1 \
  --network-interface-ids <ENI-ID> \
  --query 'NetworkInterfaces[0].Attachment.Status' \
  --output text
```

**Expected Output**: `attached`

**Full Details**:
```bash
aws ec2 describe-network-interfaces \
  --region us-east-1 \
  --network-interface-ids <ENI-ID>
```

---

## Verification Checklist

Before submitting the task, verify:

- [ ] ENI `xfusion-eni` is found in us-east-1 region
- [ ] EC2 instance `xfusion-ec2` is in **running** state
- [ ] Instance initialization is complete
- [ ] ENI status shows **in-use**
- [ ] Attachment status shows **attached**
- [ ] ENI is associated with the correct instance ID
- [ ] Device index is properly configured (typically 1 for secondary interface)

---

## Troubleshooting

### Issue: ENI attachment fails
**Possible Causes**:
- Instance is not in running state
- ENI and instance are in different availability zones
- ENI is already attached to another instance
- Device index conflict

**Solutions**:
- Ensure instance is running: `aws ec2 describe-instances --instance-ids <INSTANCE-ID>`
- Check availability zones match
- Detach ENI from other instances first
- Try a different device index (1, 2, etc.)

### Issue: Cannot find ENI or Instance
**Solution**:
- Verify you're in the correct region (us-east-1)
- Check the resource names are exactly `xfusion-eni` and `xfusion-ec2`
- Ensure tags are properly set on resources

### Issue: Permission denied errors
**Solution**:
- Verify AWS credentials are correct
- Ensure the IAM user has necessary permissions:
  - `ec2:AttachNetworkInterface`
  - `ec2:DescribeNetworkInterfaces`
  - `ec2:DescribeInstances`

---

## Important Notes

1. **Region**: All operations must be performed in **us-east-1** region
2. **Device Index**: Primary network interface uses device index 0. Additional interfaces start from 1
3. **Availability Zone**: ENI and EC2 instance must be in the same AZ
4. **Instance State**: Instance must be running or stopped (not terminated)
5. **Time Constraint**: Complete the task within the session window (1 hour)

---

## Additional AWS CLI Commands

### List all network interfaces
```bash
aws ec2 describe-network-interfaces --region us-east-1
```

### Check instance status
```bash
aws ec2 describe-instance-status \
  --region us-east-1 \
  --instance-ids <INSTANCE-ID>
```

### Detach ENI (if needed)
```bash
aws ec2 detach-network-interface \
  --region us-east-1 \
  --attachment-id <ATTACHMENT-ID>
```

---

## Success Criteria

Task is complete when:
1. ENI `xfusion-eni` is successfully attached to instance `xfusion-ec2`
2. Attachment status displays as **attached**
3. Instance initialization is complete
4. All resources are in **us-east-1** region

---

## Quick Reference Commands

```bash
# Get ENI ID
ENI_ID=$(aws ec2 describe-network-interfaces --region us-east-1 --filters "Name=tag:Name,Values=xfusion-eni" --query 'NetworkInterfaces[0].NetworkInterfaceId' --output text)

# Get Instance ID
INSTANCE_ID=$(aws ec2 describe-instances --region us-east-1 --filters "Name=tag:Name,Values=xfusion-ec2" "Name=instance-state-name,Values=running" --query 'Reservations[0].Instances[0].InstanceId' --output text)

# Attach ENI
aws ec2 attach-network-interface --region us-east-1 --network-interface-id $ENI_ID --instance-id $INSTANCE_ID --device-index 1

# Verify
aws ec2 describe-network-interfaces --region us-east-1 --network-interface-ids $ENI_ID --query 'NetworkInterfaces[0].Attachment.Status' --output text
```

---

## Support

For issues or questions during the task:
- Review AWS documentation on ENI attachment
- Check CloudTrail logs for detailed error messages
- Verify IAM permissions and resource availability

**Good luck with your task!**
