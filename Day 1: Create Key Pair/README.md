# AWS Key Pair Creation Guide

## Project Overview
This document provides instructions for creating an AWS key pair as part of the Nautilus DevOps team's incremental cloud migration strategy. The team is breaking down large migration tasks into smaller, manageable units to ensure smoother implementation and minimize disruption.

## Task Details

### Objective
Create an AWS EC2 key pair for secure SSH access to instances in the datacenter migration project.

### Requirements
- **Key Pair Name**: `datacenter-kp`
- **Key Pair Type**: `rsa`
- **AWS Region**: `us-east-1`

## AWS Credentials

### Console Access
- **Console URL**: https://315715438416.signin.aws.amazon.com/console?region=us-east-1
- **Username**: `kk_labs_user_768558`
- **Password**: `K7XAn1YhTEOU`

### Retrieving Credentials via CLI
You can retrieve credentials by running the following command on the `aws-client` host:
```bash
showcreds
```

## Implementation Steps

### Method 1: Using AWS Console

1. **Login to AWS Console**
   - Navigate to the Console URL provided above
   - Enter the username and password

2. **Navigate to EC2 Service**
   - Click on "Services" in the top navigation
   - Select "EC2" under Compute section
   - Ensure you're in the `us-east-1` region (check top-right corner)

3. **Create Key Pair**
   - In the left sidebar, under "Network & Security", click "Key Pairs"
   - Click the "Create key pair" button
   - Enter the following details:
     - **Name**: `datacenter-kp`
     - **Key pair type**: Select `RSA`
     - **Private key file format**: `.pem` (for Linux/Mac) or `.ppk` (for Windows/PuTTY)
   - Click "Create key pair"

4. **Save the Private Key**
   - The private key file will automatically download
   - Store it securely - you cannot download it again
   - Set appropriate permissions (for Linux/Mac):
     ```bash
     chmod 400 datacenter-kp.pem
     ```

### Method 2: Using AWS CLI

1. **Configure AWS CLI** (if not already configured)
   ```bash
   aws configure
   # Enter AWS Access Key ID when prompted
   # Enter AWS Secret Access Key when prompted
   # Enter region: us-east-1
   # Enter output format: json
   ```

2. **Create the Key Pair**
   ```bash
   aws ec2 create-key-pair \
     --key-name datacenter-kp \
     --key-type rsa \
     --query 'KeyMaterial' \
     --output text > datacenter-kp.pem
   ```

3. **Set Permissions**
   ```bash
   chmod 400 datacenter-kp.pem
   ```

4. **Verify Creation**
   ```bash
   aws ec2 describe-key-pairs --key-names datacenter-kp
   ```

## Verification

To verify the key pair was created successfully:

### Via AWS Console
- Navigate to EC2 > Key Pairs
- Confirm `datacenter-kp` appears in the list
- Verify the Type column shows "rsa"

### Via AWS CLI
```bash
aws ec2 describe-key-pairs --key-names datacenter-kp --region us-east-1
```

Expected output should include:
```json
{
    "KeyPairs": [
        {
            "KeyPairId": "key-xxxxxxxxx",
            "KeyFingerprint": "...",
            "KeyName": "datacenter-kp",
            "KeyType": "rsa",
            "Tags": []
        }
    ]
}
```

## Security Best Practices

1. **Protect the Private Key**
   - Never share the private key file
   - Store it in a secure location
   - Use appropriate file permissions (400 on Linux/Mac)

2. **Backup**
   - Keep a secure backup of the private key
   - Once lost, it cannot be recovered

3. **Key Rotation**
   - Consider rotating keys periodically as part of security best practices
   - Plan for key replacement in the migration strategy

## Troubleshooting

### Common Issues

**Issue**: Key pair name already exists
- **Solution**: Delete the existing key pair or choose a different name

**Issue**: Permission denied when using the key
- **Solution**: Ensure permissions are set to 400 (`chmod 400 datacenter-kp.pem`)

**Issue**: AWS CLI not configured
- **Solution**: Run `showcreds` on aws-client host and configure AWS CLI with the provided credentials

## Task Completion Checklist

- [ ] Logged into AWS Console or configured AWS CLI
- [ ] Created key pair named `datacenter-kp`
- [ ] Verified key type is RSA
- [ ] Downloaded and secured private key file
- [ ] Set appropriate permissions on private key
- [ ] Verified key pair exists in us-east-1 region
- [ ] Documented key pair location for team reference

## Next Steps

After completing this task, the key pair can be used for:
- SSH access to EC2 instances
- Secure connection to migrated services
- Automated deployment scripts requiring SSH authentication

## Task Metadata

- **Task Started**: Mon Nov 24 15:43:40 UTC 2025
- **Task Type**: Infrastructure Setup - Key Pair Creation
- **Migration Phase**: Incremental Migration - Security Setup
- **Priority**: High (Required for subsequent migration tasks)

## Support

For issues or questions regarding this task:
- Review AWS EC2 Key Pairs documentation
- Contact the Nautilus DevOps team lead
- Submit feedback through the team's collaboration platform
