# AWS Elastic IP Allocation - Nautilus DevOps Migration

## Overview
This guide provides step-by-step instructions for allocating an Elastic IP address as part of the Nautilus DevOps team's incremental AWS infrastructure migration strategy.

## AWS Credentials
- **Console URL**: https://738425594428.signin.aws.amazon.com/console?region=us-east-1
- **Username**: kk_labs_user_384071
- **Password**: oqsb4sVQe!!B
- **Session Start**: Wed Dec 10 16:52:11 UTC 2025
- **Session End**: Wed Dec 10 17:52:11 UTC 2025
- **Region**: us-east-1

## Prerequisites
- Access to the aws-client host
- Valid AWS credentials (run `showcreds` command to retrieve)
- AWS CLI installed and configured

## Task Objective
Allocate an Elastic IP address with the name tag **nautilus-eip** in the **us-east-1** region.

---

## Method 1: Using AWS CLI (Recommended)

### Step 1: Connect to AWS Client Host
```bash
# Connect to the aws-client host
# Use the terminal toggle button to expand/hide the terminal as needed
```

### Step 2: Verify AWS Credentials
```bash
# Display credentials
showcreds

# Configure AWS CLI (if needed)
aws configure
```

### Step 3: Allocate Elastic IP
```bash
# Allocate an Elastic IP address
aws ec2 allocate-address --domain vpc --region us-east-1
```

### Step 4: Tag the Elastic IP
```bash
# Replace <ALLOCATION_ID> with the AllocationId from the previous command output
aws ec2 create-tags \
  --resources <ALLOCATION_ID> \
  --tags Key=Name,Value=nautilus-eip \
  --region us-east-1
```

### Step 5: Verify the Allocation
```bash
# List all Elastic IPs with tags
aws ec2 describe-addresses --region us-east-1

# Filter by name tag
aws ec2 describe-addresses \
  --filters "Name=tag:Name,Values=nautilus-eip" \
  --region us-east-1
```

### Complete Single Command (Alternative)
```bash
# Allocate and tag in one flow
ALLOCATION_ID=$(aws ec2 allocate-address --domain vpc --region us-east-1 --query 'AllocationId' --output text)
aws ec2 create-tags --resources $ALLOCATION_ID --tags Key=Name,Value=nautilus-eip --region us-east-1
echo "Elastic IP allocated with ID: $ALLOCATION_ID"
aws ec2 describe-addresses --allocation-ids $ALLOCATION_ID --region us-east-1
```

---

## Method 2: Using AWS Management Console

### Step 1: Login to AWS Console
1. Open the console URL: https://738425594428.signin.aws.amazon.com/console?region=us-east-1
2. Enter username: `kk_labs_user_384071`
3. Enter password: `oqsb4sVQe!!B`
4. Verify the region is set to **us-east-1** (N. Virginia)

### Step 2: Navigate to EC2 Service
1. Click on **Services** in the top menu
2. Select **EC2** under "Compute" section
3. Or search for "EC2" in the search bar

### Step 3: Access Elastic IPs
1. In the left navigation pane, scroll down to **Network & Security**
2. Click on **Elastic IPs**

### Step 4: Allocate Elastic IP Address
1. Click the **Allocate Elastic IP address** button
2. In the configuration page:
   - **Network Border Group**: Select `us-east-1`
   - **Public IPv4 address pool**: Keep default (Amazon's pool of IPv4 addresses)
3. Optionally add tags:
   - Click **Add new tag**
   - **Key**: `Name`
   - **Value**: `nautilus-eip`
4. Click **Allocate**

### Step 5: Verify Allocation
1. You should see a success message with the allocated IP address
2. The Elastic IP will appear in the list with the name **nautilus-eip**
3. Note down the **Allocation ID** and **Public IPv4 address** for future reference

---

## Verification Checklist

- [ ] Elastic IP successfully allocated
- [ ] Resource tagged with Name: `nautilus-eip`
- [ ] Region confirmed as `us-east-1`
- [ ] Allocation ID recorded
- [ ] Public IPv4 address noted

## Expected Output

When successful, you should see output similar to:

```json
{
    "PublicIp": "X.X.X.X",
    "AllocationId": "eipalloc-xxxxxxxxxxxxxxxxx",
    "Domain": "vpc",
    "NetworkBorderGroup": "us-east-1"
}
```

## Important Notes

1. **Region Compliance**: Ensure all resources are created in **us-east-1** region only
2. **Session Time**: Complete the task within the session window (before 17:52:11 UTC)
3. **Elastic IP Charges**: Elastic IPs are free when associated with a running instance, but charges apply for unassociated IPs
4. **Terminal Toggle**: Use the expand/collapse toggle button to show/hide the terminal as needed during execution

## Troubleshooting

### Issue: Permission Denied
```bash
# Verify credentials are correctly configured
aws sts get-caller-identity
```

### Issue: Wrong Region
```bash
# Explicitly set region
export AWS_DEFAULT_REGION=us-east-1
```

### Issue: Cannot Find Allocated IP
```bash
# Check all addresses in the region
aws ec2 describe-addresses --region us-east-1 --output table
```

## Cleanup (Optional)

To release the Elastic IP when no longer needed:

```bash
# Get the allocation ID
ALLOCATION_ID=$(aws ec2 describe-addresses \
  --filters "Name=tag:Name,Values=nautilus-eip" \
  --query 'Addresses[0].AllocationId' \
  --output text \
  --region us-east-1)

# Release the Elastic IP
aws ec2 release-address --allocation-id $ALLOCATION_ID --region us-east-1
```

---

## Migration Strategy Context

This task is part of the Nautilus DevOps team's incremental migration approach:
- **Objective**: Migrate infrastructure to AWS in manageable phases
- **Approach**: Break down large tasks into smaller units
- **Benefits**: 
  - Better control and risk mitigation
  - Minimized disruption to operations
  - Optimized resource utilization
  - Easier rollback if issues arise

## Next Steps

After completing this task:
1. Document the Elastic IP allocation details
2. Proceed to the next phase of the migration plan
3. Associate the Elastic IP with relevant EC2 instances when needed
4. Update network configuration documentation

---

**Task Status**: Ready for execution  
**Estimated Time**: 5-10 minutes  
**Difficulty**: Beginner  
**Last Updated**: December 10, 2025
