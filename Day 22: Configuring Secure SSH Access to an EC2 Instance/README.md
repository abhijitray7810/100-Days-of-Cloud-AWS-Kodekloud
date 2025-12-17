# DevOps EC2 Instance Setup - README
![image]()
## Overview
This guide provides step-by-step instructions for setting up a new EC2 instance (`devops-ec2`) with secure SSH access from the `aws-client` landing host.

## Prerequisites
- Access to `aws-client` host
- AWS credentials (available via `showcreds` command)
- AWS CLI installed on `aws-client`
![image]()
## AWS Credentials
```
Console URL: https://374085604821.signin.aws.amazon.com/console?region=us-east-1
Username: kk_labs_user_948159
Password: Xq%87%@b%lRP
Region: us-east-1
Valid: Wed Dec 17 14:19:50 UTC 2025 - Wed Dec 17 15:19:50 UTC 2025
```

## Implementation Steps
![image]()
### 1. Configure AWS CLI on aws-client
```bash
# SSH into aws-client host
ssh root@aws-client

# Display credentials
showcreds

# Configure AWS CLI
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: us-east-1
# - Default output format: json
```

### 2. Generate SSH Key Pair
```bash
# Check if SSH key already exists
ls -la /root/.ssh/

# Generate new SSH key if it doesn't exist
ssh-keygen -t rsa -b 2048 -f /root/.ssh/devops-key -N ""

# Verify key creation
ls -la /root/.ssh/devops-key*
```

### 3. Create EC2 Key Pair in AWS
```bash
# Import the public key to AWS
aws ec2 import-key-pair \
  --key-name devops-key \
  --public-key-material fileb:///root/.ssh/devops-key.pub \
  --region us-east-1

# Verify key pair creation
aws ec2 describe-key-pairs --key-names devops-key --region us-east-1
```

### 4. Create Security Group
```bash
# Create security group
aws ec2 create-security-group \
  --group-name devops-sg \
  --description "Security group for devops-ec2 instance" \
  --region us-east-1

# Get the security group ID
SG_ID=$(aws ec2 describe-security-groups \
  --group-names devops-sg \
  --query 'SecurityGroups[0].GroupId' \
  --output text \
  --region us-east-1)

# Add SSH access rule
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region us-east-1
```

### 5. Launch EC2 Instance
```bash
# Get the latest Amazon Linux 2 AMI ID
AMI_ID=$(aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text \
  --region us-east-1)

# Launch t2.micro instance
aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t2.micro \
  --key-name devops-key \
  --security-group-ids $SG_ID \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=devops-ec2}]' \
  --region us-east-1

# Get instance ID
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devops-ec2" "Name=instance-state-name,Values=running,pending" \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text \
  --region us-east-1)

# Wait for instance to be running
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region us-east-1

# Get public IP address
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text \
  --region us-east-1)

echo "Instance Public IP: $PUBLIC_IP"
```

### 6. Test SSH Connection
```bash
# Wait a moment for SSH service to be ready
sleep 30

# Test SSH connection (Amazon Linux 2 uses 'ec2-user' by default)
ssh -i /root/.ssh/devops-key ec2-user@$PUBLIC_IP

# Once connected, verify instance details
hostname
uname -a
exit
```

### 7. Configure Root User Access (If Required)
```bash
# Connect to instance
ssh -i /root/.ssh/devops-key ec2-user@$PUBLIC_IP

# Switch to root (if needed)
sudo su -

# Add your public key to root's authorized_keys
sudo mkdir -p /root/.ssh
sudo chmod 700 /root/.ssh
echo "YOUR_PUBLIC_KEY_CONTENT" | sudo tee -a /root/.ssh/authorized_keys
sudo chmod 600 /root/.ssh/authorized_keys

# Enable root login in SSH config (if required - NOT RECOMMENDED for production)
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

exit
```

### 8. Add SSH Config Entry (Optional)
```bash
# On aws-client, add entry to SSH config
cat >> /root/.ssh/config << EOF

Host devops-ec2
    HostName $PUBLIC_IP
    User ec2-user
    IdentityFile /root/.ssh/devops-key
    StrictHostKeyChecking no
EOF

chmod 600 /root/.ssh/config

# Now you can connect simply with:
ssh devops-ec2
```

## Verification Checklist
- [ ] SSH key pair created in `/root/.ssh/` on aws-client
- [ ] EC2 key pair imported to AWS
- [ ] Security group created with SSH access
- [ ] EC2 instance launched with type `t2.micro`
- [ ] Instance tagged with name `devops-ec2`
- [ ] SSH connection successful from aws-client
- [ ] Passwordless authentication working

## Common Commands

### Check Instance Status
```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devops-ec2" \
  --query 'Reservations[0].Instances[0].[InstanceId,State.Name,PublicIpAddress]' \
  --output table \
  --region us-east-1
```

### Stop Instance
```bash
aws ec2 stop-instances --instance-ids $INSTANCE_ID --region us-east-1
```

### Start Instance
```bash
aws ec2 start-instances --instance-ids $INSTANCE_ID --region us-east-1
```

### Terminate Instance
```bash
aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region us-east-1
```

## Troubleshooting

### Cannot Connect via SSH
1. Verify security group allows SSH (port 22)
2. Check instance is in "running" state
3. Verify correct SSH key is being used
4. Check SSH key permissions (should be 600)
5. Wait for instance initialization to complete

### Permission Denied
1. Verify correct username (ec2-user for Amazon Linux)
2. Check SSH key permissions
3. Verify public key is in authorized_keys on instance

### Timeout Connecting
1. Check security group rules
2. Verify public IP address is correct
3. Check VPC and subnet configurations
4. Verify internet gateway is attached

## Security Best Practices
1. ✅ Use SSH key authentication (no passwords)
2. ✅ Restrict SSH access to specific IPs when possible
3. ⚠️ Avoid enabling root login (use sudo instead)
4. ✅ Keep SSH keys secure (600 permissions)
5. ✅ Regularly rotate SSH keys
6. ✅ Use security groups to limit access
7. ✅ Monitor instance access logs

## Cleanup (When Done)
```bash
# Terminate instance
aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region us-east-1

# Wait for termination
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID --region us-east-1

# Delete security group
aws ec2 delete-security-group --group-id $SG_ID --region us-east-1

# Delete key pair from AWS
aws ec2 delete-key-pair --key-name devops-key --region us-east-1

# Optionally remove local SSH keys
rm -f /root/.ssh/devops-key*
```

## Notes
- Instance type: `t2.micro` (free tier eligible)
- Region: `us-east-1` (as required)
- Default user for Amazon Linux 2: `ec2-user`
- Root access should be avoided in production environments
- AWS credentials are time-limited (valid for 1 hour)

## Support
For issues or questions, contact the Nautilus DevOps team.

---
**Created:** Wed Dec 17, 2025  
**Last Updated:** Wed Dec 17, 2025
