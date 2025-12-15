# Nautilus EC2 AMI Creation Guide
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/cf2c9fb5c582b0be5ddc6cd8e568073d0f74aa52/Day%2013%3A%20Create%20AMI%20from%20EC2%20Instance/Screenshot%202025-12-16%20000648.png)
## Overview
This guide provides step-by-step instructions for creating an Amazon Machine Image (AMI) from an existing EC2 instance as part of the Nautilus DevOps team's incremental AWS migration strategy.

## Objective
Create an AMI named `nautilus-ec2-ami` from the existing EC2 instance `nautilus-ec2` in the `us-east-1` region.

## Prerequisites
- Access to AWS Management Console or AWS CLI
- Valid AWS credentials
- Existing EC2 instance named `nautilus-ec2`
- Permissions to create AMIs

## AWS Credentials

```
Console URL: https://482856388587.signin.aws.amazon.com/console?region=us-east-1
Username: kk_labs_user_527410
Password: BiY!QgA1N^x%
Region: us-east-1
Session Duration: 1 hour (Mon Dec 15 17:16:00 - 18:16:00 UTC 2025)
```

**Note**: Credentials can be retrieved by running `showcreds` command on the aws-client host.

## Method 1: Using AWS Management Console

### Step 1: Login to AWS Console
1. Navigate to the Console URL
2. Enter the username and password provided
3. Ensure you're in the `us-east-1` region (check top-right corner)

### Step 2: Navigate to EC2 Dashboard
1. From the AWS Console home, search for "EC2" in the search bar
2. Click on "EC2" to open the EC2 Dashboard

### Step 3: Locate the Source Instance
1. In the left sidebar, click on "Instances"
2. Find the instance named `nautilus-ec2`
3. Select the instance by clicking the checkbox next to it

### Step 4: Create the AMI
1. Click on "Actions" dropdown at the top
2. Navigate to "Image and templates" > "Create image"
3. Fill in the following details:
   - **Image name**: `nautilus-ec2-ami`
   - **Image description**: (Optional) "AMI created for Nautilus migration project"
   - **No reboot**: Leave unchecked (recommended for data consistency)
   - Keep other settings as default
4. Click "Create image" button

### Step 5: Verify AMI Creation
1. In the left sidebar, click on "AMIs" under "Images"
2. Locate `nautilus-ec2-ami` in the list
3. Wait for the Status to change from "pending" to "available"
4. This may take several minutes depending on instance size

## Method 2: Using AWS CLI

### Step 1: Configure AWS CLI
```bash
# Run on aws-client host
showcreds

# Configure AWS credentials
aws configure set aws_access_key_id <ACCESS_KEY>
aws configure set aws_secret_access_key <SECRET_KEY>
aws configure set region us-east-1
```

### Step 2: Get Instance ID
```bash
# Find the instance ID of nautilus-ec2
aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=nautilus-ec2" \
    --query "Reservations[*].Instances[*].InstanceId" \
    --output text
```

### Step 3: Create the AMI
```bash
# Replace <INSTANCE_ID> with the actual instance ID
aws ec2 create-image \
    --instance-id <INSTANCE_ID> \
    --name "nautilus-ec2-ami" \
    --description "AMI created for Nautilus migration project" \
    --no-reboot
```

**Note**: Remove `--no-reboot` flag if you want to ensure filesystem consistency (will cause brief downtime)

### Step 4: Verify AMI Status
```bash
# Get the AMI ID from the previous command output, then check status
aws ec2 describe-images \
    --filters "Name=name,Values=nautilus-ec2-ami" \
    --query "Images[*].[ImageId,Name,State]" \
    --output table
```

### Step 5: Wait for AMI to be Available
```bash
# Monitor until State shows 'available'
aws ec2 wait image-available \
    --filters "Name=name,Values=nautilus-ec2-ami"
```

## Verification Checklist

- [ ] AMI name is exactly `nautilus-ec2-ami`
- [ ] AMI is created in `us-east-1` region
- [ ] AMI status shows as "available"
- [ ] AMI appears in the AMIs list in EC2 console
- [ ] Source instance `nautilus-ec2` is still running (if using no-reboot)

## Important Notes

1. **Region**: All operations must be performed in `us-east-1` region
2. **Naming**: AMI name must be exactly `nautilus-ec2-ami` (case-sensitive)
3. **Reboot Behavior**: By default, AWS will reboot the instance to ensure filesystem consistency
4. **Time Required**: AMI creation typically takes 5-15 minutes depending on instance size
5. **Session Timeout**: Complete the task within the 1-hour credential validity window

## Troubleshooting

### Issue: Instance not found
**Solution**: Verify you're in the correct region (us-east-1) and the instance name is correct

### Issue: Insufficient permissions
**Solution**: Verify your credentials are correct and have the necessary IAM permissions

### Issue: AMI stuck in "pending" state
**Solution**: Wait longer (can take up to 15-20 minutes for large instances). If it persists, check CloudTrail logs for errors

### Issue: Session expired
**Solution**: Re-run `showcreds` on aws-client host to get new credentials

## Expected Outcome

Upon successful completion:
- An AMI named `nautilus-ec2-ami` will be created
- The AMI will be in "available" state
- The AMI can be used to launch new EC2 instances identical to `nautilus-ec2`
- The source instance `nautilus-ec2` remains operational

## Next Steps in Migration

This AMI can now be used for:
1. Creating identical instances in other availability zones
2. Disaster recovery scenarios
3. Scaling operations
4. Testing and development environments
5. Further migration phases

## References

- [AWS EC2 AMI Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)
- [Creating an AMI from an Instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/creating-an-ami-ebs.html)
- [AWS CLI EC2 Commands](https://docs.aws.amazon.com/cli/latest/reference/ec2/)

---

**Document Version**: 1.0  
**Last Updated**: December 2025  
**Maintained by**: Nautilus DevOps Team
