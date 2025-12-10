# AWS EC2 Instance Migration 
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/3279dd22ca240bc14df681de9661f05d0eebdddd/Day%206%3A%20Launch%20EC2%20Instance/Screenshot%202025-12-10%20234324.png)

## Overview
This task involves creating an EC2 instance as part of the Nautilus DevOps team's incremental AWS cloud migration strategy.

## Instance Requirements

| Parameter | Value |
|-----------|-------|
| Instance Name | `datacenter-ec2` |
| AMI | Amazon Linux |
| Instance Type | `t2.micro` |
| Key Pair | `datacenter-kp` (RSA) |
| Security Group | Default |
| Region | `us-east-1` |

## AWS Credentials

- **Console URL**: https://687042127375.signin.aws.amazon.com/console?region=us-east-1
- **Username**: `kk_labs_user_743001`
- **Password**: `V%h2BfSfZ%g^`
- **Valid Period**: Wed Dec 10 18:09:59 UTC 2025 - Wed Dec 10 19:09:59 UTC 2025

## Steps to Complete

1. **Access AWS Console** using the provided credentials
2. **Navigate to EC2 Dashboard** in us-east-1 region
3. **Create RSA Key Pair** named `datacenter-kp`
4. **Launch EC2 Instance**:
   - Select Amazon Linux AMI
   - Choose t2.micro instance type
   - Attach default security group
   - Use the created key pair
   - Tag with Name: `datacenter-ec2`
5. **Verify** instance is running

## Alternative: AWS CLI

Retrieve credentials on aws-client host:
```bash
showcreds
```

Create key pair and launch instance using AWS CLI commands.

## Notes
- Ensure you're working in the **us-east-1** region
- Session expires after 1 hour
- Use terminal toggle button to show/hide aws-client machine interface
