# AWS EBS Volume Attachment Guide
![image]()
## Overview
This guide provides step-by-step instructions for attaching an existing EBS volume (`nautilus-volume`) to an existing EC2 instance (`nautilus-ec2`) in the `us-east-1` region with device name `/dev/sdb`.

## Prerequisites
- AWS account credentials
- Access to AWS Management Console or AWS CLI
- Existing EC2 instance: `nautilus-ec2`
- Existing EBS volume: `nautilus-volume`
- Both resources must be in the same availability zone within `us-east-1` region
![image]()
## AWS Credentials
```
Console URL: https://022390610537.signin.aws.amazon.com/console?region=us-east-1
Username: kk_labs_user_699024
Password: 1@BN9T@ig0pU
Region: us-east-1
Session Duration: 1 hour (16:59:32 UTC - 17:59:32 UTC)
```

## Method 1: Using AWS Management Console

### Step 1: Access AWS Console
1. Open your web browser
2. Navigate to: `https://022390610537.signin.aws.amazon.com/console?region=us-east-1`
3. Enter the credentials:
   - **Username**: `kk_labs_user_699024`
   - **Password**: `1@BN9T@ig0pU`
4. Click **Sign In**

### Step 2: Navigate to EC2 Dashboard
1. In the AWS Management Console, click on **Services** in the top menu
2. Under **Compute**, select **EC2**
3. Verify you are in the **us-east-1** region (check the top-right corner)

### Step 3: Locate the EC2 Instance
1. In the left navigation pane, click **Instances**
2. Find and select the instance named **nautilus-ec2**
3. Note the **Availability Zone** (e.g., us-east-1a, us-east-1b, etc.)
4. Verify the instance **State** is "Running" (if stopped, you can still attach, but it's better when running)

### Step 4: Locate the EBS Volume
1. In the left navigation pane, click **Volumes** (under Elastic Block Store)
2. Find the volume named **nautilus-volume**
3. Verify the volume **State** is "available"
4. Verify the volume's **Availability Zone** matches the EC2 instance's zone
   - **Important**: Volume and instance must be in the same availability zone

### Step 5: Attach the Volume
1. Select the **nautilus-volume** volume (checkbox)
2. Click **Actions** dropdown button at the top
3. Select **Attach volume**
4. In the "Attach volume" dialog:
   - **Instance**: Start typing "nautilus-ec2" and select it from the dropdown
   - **Device name**: Enter `/dev/sdb`
5. Click **Attach volume** button
6. Wait for the attachment to complete (status changes to "in-use")

### Step 6: Verify Attachment
1. Stay on the **Volumes** page
2. Select **nautilus-volume**
3. Check the **Attachment information** section at the bottom:
   - **Instance ID**: Should show the nautilus-ec2 instance ID
   - **Device**: Should show `/dev/sdb`
   - **State**: Should show "attached"

## Method 2: Using AWS CLI

### Step 1: Connect to AWS Client Host
```bash
# SSH into the aws-client host (if applicable)
ssh user@aws-client-host
```

### Step 2: Retrieve and Configure Credentials
```bash
# Run the showcreds command to retrieve credentials
showcreds

# Configure AWS CLI with the credentials
aws configure
# Enter the Access Key ID when prompted
# Enter the Secret Access Key when prompted
# Default region name: us-east-1
# Default output format: json
```

### Step 3: Verify Existing Resources
```bash
# List EC2 instances to find nautilus-ec2
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=nautilus-ec2" \
  --region us-east-1 \
  --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],State.Name,Placement.AvailabilityZone]' \
  --output table

# List EBS volumes to find nautilus-volume
aws ec2 describe-volumes \
  --filters "Name=tag:Name,Values=nautilus-volume" \
  --region us-east-1 \
  --query 'Volumes[*].[VolumeId,Tags[?Key==`Name`].Value|[0],State,AvailabilityZone]' \
  --output table
```

### Step 4: Get Resource IDs
```bash
# Get the Instance ID
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=nautilus-ec2" \
  --region us-east-1 \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text)

echo "Instance ID: $INSTANCE_ID"

# Get the Volume ID
VOLUME_ID=$(aws ec2 describe-volumes \
  --filters "Name=tag:Name,Values=nautilus-volume" \
  --region us-east-1 \
  --query 'Volumes[*].VolumeId' \
  --output text)

echo "Volume ID: $VOLUME_ID"
```

### Step 5: Attach the Volume
```bash
# Attach the volume to the instance with device name /dev/sdb
aws ec2 attach-volume \
  --volume-id $VOLUME_ID \
  --instance-id $INSTANCE_ID \
  --device /dev/sdb \
  --region us-east-1
```

### Step 6: Verify Attachment
```bash
# Check the volume attachment status
aws ec2 describe-volumes \
  --volume-ids $VOLUME_ID \
  --region us-east-1 \
  --query 'Volumes[*].[VolumeId,State,Attachments[*].[InstanceId,Device,State]]' \
  --output table

# Alternative: Describe the specific volume
aws ec2 describe-volumes \
  --volume-ids $VOLUME_ID \
  --region us-east-1
```

## Expected Output

### Successful Attachment Response
```json
{
    "AttachTime": "2025-12-15T17:00:00.000Z",
    "Device": "/dev/sdb",
    "InstanceId": "i-xxxxxxxxxxxxxxxxx",
    "State": "attaching",
    "VolumeId": "vol-xxxxxxxxxxxxxxxxx"
}
```

### Volume Status After Attachment
- **State**: in-use
- **Attachment State**: attached
- **Device**: /dev/sdb
- **Instance ID**: (nautilus-ec2 instance ID)

## Troubleshooting

### Issue 1: Volume and Instance in Different Availability Zones
**Error**: "The volume 'vol-xxx' is not in the same availability zone as instance 'i-xxx'"

**Solution**: 
- You cannot attach a volume to an instance in a different availability zone
- Create a snapshot of the volume and create a new volume in the correct zone
- Or, migrate the instance to the volume's availability zone

### Issue 2: Volume Already Attached
**Error**: "Volume 'vol-xxx' is already attached to an instance"

**Solution**:
1. Detach the volume from the current instance first
2. Wait for the state to become "available"
3. Then attach to nautilus-ec2

### Issue 3: Device Name Already in Use
**Error**: "Device name '/dev/sdb' is already in use"

**Solution**:
- Check existing volume attachments on the instance
- Use a different device name (e.g., /dev/sdc, /dev/sdf, etc.)

### Issue 4: Permission Denied
**Error**: "You are not authorized to perform this operation"

**Solution**:
- Verify your IAM user has the necessary permissions (ec2:AttachVolume)
- Check if you're using the correct AWS credentials
- Ensure you're in the correct AWS region (us-east-1)

## Post-Attachment Steps (Optional)

If you need to use the volume within the EC2 instance:

### Step 1: Connect to the EC2 Instance
```bash
# SSH into the instance (requires key pair)
ssh -i your-key.pem ec2-user@<instance-public-ip>
```

### Step 2: Verify the Volume is Visible
```bash
# List block devices
lsblk

# You should see the new device (might appear as /dev/xvdb instead of /dev/sdb)
```

### Step 3: Format the Volume (Only if new/empty)
```bash
# Check if the volume has a filesystem
sudo file -s /dev/xvdb

# If output is "data", the volume is empty and needs formatting
sudo mkfs -t ext4 /dev/xvdb
```

### Step 4: Mount the Volume
```bash
# Create a mount point
sudo mkdir /mnt/data

# Mount the volume
sudo mount /dev/xvdb /mnt/data

# Verify mount
df -h
```

### Step 5: Configure Auto-Mount on Reboot (Optional)
```bash
# Get the UUID
sudo blkid /dev/xvdb

# Edit fstab
sudo nano /etc/fstab

# Add this line (replace UUID with your actual UUID):
# UUID=your-uuid-here  /mnt/data  ext4  defaults,nofail  0  2

# Test the fstab entry
sudo mount -a
```

## Important Notes

1. **Availability Zone**: The EBS volume and EC2 instance must be in the same availability zone
2. **Volume State**: The volume must be in "available" state before attaching
3. **Device Names**: Linux instances can use `/dev/sd[f-p]` or `/dev/xvd[b-z]`
4. **Instance State**: You can attach volumes to both running and stopped instances
5. **Time Constraint**: Complete the task within the 1-hour session window
6. **Region**: Ensure all operations are performed in `us-east-1` region only

## Verification Checklist

- [ ] Successfully logged into AWS Console
- [ ] Located nautilus-ec2 instance in us-east-1
- [ ] Located nautilus-volume in us-east-1
- [ ] Verified both resources are in the same availability zone
- [ ] Attached volume with device name /dev/sdb
- [ ] Verified attachment status shows "attached"
- [ ] Confirmed device name is /dev/sdb in attachment information

## Additional Resources

- [AWS EBS Volume Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volumes.html)
- [Attaching EBS Volumes](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-attaching-volume.html)
- [Device Naming on Linux Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html)

## Completion Confirmation

Task is complete when:
1. The nautilus-volume shows State: "in-use"
2. Attachment information shows:
   - Instance: nautilus-ec2 (instance-id)
   - Device: /dev/sdb
   - State: attached
