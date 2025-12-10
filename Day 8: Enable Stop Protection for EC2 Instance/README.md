# AWS EC2 Stop Protection - README
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/3432073556512f8231cd0562dc7941cbda1ac354/Day%208%3A%20Enable%20Stop%20Protection%20for%20EC2%20Instance/Screenshot%202025-12-11%20000334.png)
![image]()
## Overview
Enable stop protection for an existing EC2 instance as part of the Nautilus DevOps team's AWS migration configuration updates.

## Task Requirements

| Parameter | Value |
|-----------|-------|
| Instance Name | `datacenter-ec2` |
| Region | `us-east-1` |
| Action | Enable Stop Protection |

## AWS Credentials

- **Console URL**: https://427001312714.signin.aws.amazon.com/console?region=us-east-1
- **Username**: `kk_labs_user_406596`
- **Password**: `Ah6%Q^XYkp^M`
- **Valid Period**: Wed Dec 10 18:31:20 UTC 2025 - Wed Dec 10 19:31:20 UTC 2025

## Steps to Complete

### Method 1: AWS Console

1. **Login** to AWS Console using provided credentials
2. **Navigate** to EC2 Dashboard in us-east-1 region
3. **Locate** the instance named `datacenter-ec2`
4. **Select** the instance
5. **Click** Actions → Instance settings → Change stop protection
6. **Enable** stop protection
7. **Save** changes

### Method 2: AWS CLI

```bash
# Retrieve credentials
showcreds

# Get instance ID
aws ec2 describe-instances --region us-east-1 \
  --filters "Name=tag:Name,Values=datacenter-ec2" \
  --query "Reservations[0].Instances[0].InstanceId" --output text

# Enable stop protection
aws ec2 modify-instance-attribute --region us-east-1 \
  --instance-id <INSTANCE_ID> \
  --disable-api-stop
```

## Verification

Confirm stop protection is enabled:
- Console: Check instance details → Instance settings
- CLI: `aws ec2 describe-instance-attribute --instance-id <INSTANCE_ID> --attribute disableApiStop --region us-east-1`

## Notes
- Work only in **us-east-1** region
- Session valid for 1 hour
- Use terminal toggle to show/hide aws-client interface
- Stop protection prevents accidental instance stops via API/Console
