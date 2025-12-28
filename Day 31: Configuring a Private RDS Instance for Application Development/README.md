# AWS RDS Instance Provisioning Guide

## Task Overview
Provision a private MySQL RDS instance for the Nautilus Development Team using AWS Free Tier specifications.

## Requirements
![image]()
### Instance Specifications
- **Instance Name**: `nautilus-rds`
- **Template**: Sandbox (Free Tier)
- **Instance Type**: `db.t3.micro`
- **Database Engine**: MySQL 8.4.x
- **Storage Autoscaling**: Enabled with 50GB threshold
- **Region**: `us-east-1`
- **Status**: Available before submission

## AWS Credentials
- **Console URL**: https://374085604821.signin.aws.amazon.com/console?region=us-east-1
- **Username**: `kk_labs_user_485845`
- **Password**: `361nf!7IEJjJ`
- **Session**: Valid until Sun Dec 28 13:43:09 UTC 2025

## Step-by-Step Implementation
![image]()
### Option 1: AWS Management Console

1. **Login to AWS Console**
   - Navigate to the Console URL
   - Enter the provided credentials
   - Ensure you're in the `us-east-1` region

2. **Navigate to RDS Service**
   - Search for "RDS" in the AWS services search bar
   - Click on "RDS" to open the RDS Dashboard

3. **Create Database**
   - Click "Create database" button
   - Choose "Standard create" method

4. **Engine Configuration**
   - **Engine type**: MySQL
   - **Version**: Select MySQL 8.4.x (latest available in 8.4 series)
   - **Templates**: Select "Free tier"

5. **Settings**
   - **DB instance identifier**: `nautilus-rds`
   - **Master username**: Leave as default or set to `admin`
   - **Master password**: Create a secure password (save it securely)

6. **Instance Configuration**
   - **DB instance class**: 
     - Select "Burstable classes"
     - Choose `db.t3.micro`

7. **Storage Configuration**
   - **Storage type**: General Purpose SSD (gp2 or gp3)
   - **Allocated storage**: 20 GB (default for free tier)
   - **Storage autoscaling**: 
     - ✅ Enable storage autoscaling
     - **Maximum storage threshold**: `50` GB

8. **Connectivity**
   - **VPC**: Select default VPC
   - **Public access**: No (for private instance)
   - **VPC security group**: Create new or use existing

9. **Additional Configuration**
   - Keep remaining settings as default
   - Optionally disable automated backups if not needed for development

10. **Create Database**
    - Review all settings
    - Click "Create database"
    - Wait for the instance to become "Available" (typically 5-10 minutes)

### Option 2: AWS CLI

```bash
# Configure AWS CLI (if needed)
aws configure
# Enter Access Key ID, Secret Access Key, region (us-east-1), and output format

# Create RDS Instance
aws rds create-db-instance \
    --db-instance-identifier nautilus-rds \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --engine-version 8.4.3 \
    --master-username admin \
    --master-user-password YourSecurePassword123! \
    --allocated-storage 20 \
    --max-allocated-storage 50 \
    --no-publicly-accessible \
    --backup-retention-period 0 \
    --region us-east-1

# Check instance status
aws rds describe-db-instances \
    --db-instance-identifier nautilus-rds \
    --query 'DBInstances[0].DBInstanceStatus' \
    --region us-east-1 \
    --output text

# Wait for instance to be available
aws rds wait db-instance-available \
    --db-instance-identifier nautilus-rds \
    --region us-east-1
```

## Verification Steps

1. **Check Instance Status**
   ```bash
   aws rds describe-db-instances \
       --db-instance-identifier nautilus-rds \
       --region us-east-1
   ```

2. **Verify Configuration**
   - Instance type: `db.t3.micro`
   - Engine: MySQL 8.4.x
   - Status: `available`
   - Max allocated storage: 50 GB
   - Public accessibility: `false` (private)

3. **In Console**
   - Navigate to RDS Dashboard
   - Find `nautilus-rds` in the database list
   - Verify status shows "Available"
   - Check configuration details match requirements

## Important Notes

- **Storage Autoscaling**: When enabled, AWS will automatically scale storage up to the maximum threshold (50GB) when the instance runs low on space
- **Free Tier Limits**: db.t3.micro with 20GB storage qualifies for AWS free tier (750 hours/month for 12 months)
- **Private Instance**: No public IP means the database is only accessible from within the VPC
- **Backup Retention**: Can be set to 0 for development to save costs
- **Security**: Save the master password securely - it cannot be retrieved later
- **Provisioning Time**: Typically takes 5-10 minutes for the instance to reach "Available" state

## Troubleshooting

- **Instance stuck in "Creating" state**: Wait up to 15 minutes; RDS provisioning can take time
- **Insufficient permissions**: Ensure IAM user has RDS creation permissions
- **VPC errors**: Verify default VPC exists in us-east-1
- **Free tier constraints**: Ensure no other free tier RDS instances are running

## Cleanup (When No Longer Needed)

```bash
# Delete RDS instance
aws rds delete-db-instance \
    --db-instance-identifier nautilus-rds \
    --skip-final-snapshot \
    --region us-east-1
```

## Success Criteria

✅ RDS instance named `nautilus-rds` created  
✅ Instance type is `db.t3.micro`  
✅ MySQL engine version 8.4.x configured  
✅ Storage autoscaling enabled with 50GB threshold  
✅ Instance is in "Available" state  
✅ Instance is private (not publicly accessible)  
✅ Deployed in `us-east-1` region

---

**Created for**: Nautilus Development Team  
**Region**: us-east-1  
**Date**: December 28, 2025
