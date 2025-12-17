# AWS IAM Role Setup Guide
![image]()
## Objective
Create an IAM role named `iamrole_jim` for EC2 service with an attached policy `iampolicy_jim` in the us-east-1 region.

## Prerequisites
- Access to AWS Console or AWS CLI
- AWS Credentials provided below
![image]()
## AWS Credentials
```
Console URL: https://892386795191.signin.aws.amazon.com/console?region=us-east-1
Username: kk_labs_user_551334
Password: OXcB5mW^iWx%
Region: us-east-1
Session Valid: Wed Dec 17 13:44:52 UTC 2025 - Wed Dec 17 14:44:52 UTC 2025
```
![image]()
## Requirements
1. **IAM Role Name**: `iamrole_jim`
2. **Entity Type**: AWS Service
3. **Use Case**: EC2
4. **Attached Policy**: `iampolicy_jim`
5. **Region**: us-east-1

---

## Method 1: AWS Management Console

### Step 1: Login to AWS Console
1. Navigate to: https://892386795191.signin.aws.amazon.com/console?region=us-east-1
2. Enter the username: `kk_labs_user_551334`
3. Enter the password: `OXcB5mW^iWx%`
4. Verify you are in the **us-east-1** region (top-right corner)

### Step 2: Create/Verify the IAM Policy
1. In the AWS Console, search for **IAM** in the services search bar
2. Click on **Policies** in the left navigation panel
3. Check if policy `iampolicy_jim` exists:
   - If it exists, note it for later attachment
   - If it doesn't exist, you'll need to create it first:
     - Click **Create policy**
     - Choose either JSON or Visual editor
     - Define the required permissions
     - Click **Next: Tags** (optional)
     - Click **Next: Review**
     - Enter policy name: `iampolicy_jim`
     - Click **Create policy**

### Step 3: Create the IAM Role
1. In IAM dashboard, click **Roles** in the left navigation panel
2. Click **Create role** button
3. **Select trusted entity**:
   - Choose **AWS service** as the entity type
   - Under **Use case**, select **EC2**
   - Click **Next**
4. **Add permissions**:
   - In the search box, type: `iampolicy_jim`
   - Check the box next to `iampolicy_jim` policy
   - Click **Next**
5. **Name, review, and create**:
   - Enter Role name: `iamrole_jim`
   - (Optional) Add description: "IAM role for EC2 instances with iampolicy_jim policy"
   - (Optional) Add tags if needed
   - Review the configuration
   - Click **Create role**

### Step 4: Verify the Role
1. In the Roles list, search for `iamrole_jim`
2. Click on the role name to view details
3. Verify:
   - **Trusted entities**: Should show `ec2.amazonaws.com`
   - **Permissions policies**: Should show `iampolicy_jim` attached
   - **Region**: Ensure you're in us-east-1

---

## Method 2: AWS CLI

### Step 1: Configure AWS CLI (if using aws-client host)
```bash
# Run showcreds command to retrieve credentials
showcreds

# Configure AWS CLI with the credentials
aws configure
# AWS Access Key ID: [from showcreds output]
# AWS Secret Access Key: [from showcreds output]
# Default region name: us-east-1
# Default output format: json
```

### Step 2: Create the Trust Policy Document
Create a file named `trust-policy.json`:
```bash
cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
```

### Step 3: Create the IAM Role
```bash
# Create the IAM role with EC2 trust relationship
aws iam create-role \
  --role-name iamrole_jim \
  --assume-role-policy-document file://trust-policy.json \
  --description "IAM role for EC2 instances" \
  --region us-east-1
```

### Step 4: Attach the Policy to the Role
```bash
# First, verify the policy exists
aws iam get-policy \
  --policy-arn arn:aws:iam::892386795191:account-alias/policy/iampolicy_jim \
  --region us-east-1

# If policy exists, attach it to the role
aws iam attach-role-policy \
  --role-name iamrole_jim \
  --policy-arn arn:aws:iam::892386795191:policy/iampolicy_jim \
  --region us-east-1
```

**Note**: If the policy doesn't exist, you'll need to create it first using `aws iam create-policy`.

### Step 5: Verify the Role Creation
```bash
# Get role details
aws iam get-role \
  --role-name iamrole_jim \
  --region us-east-1

# List attached policies
aws iam list-attached-role-policies \
  --role-name iamrole_jim \
  --region us-east-1
```

---

## Verification Checklist

- [ ] IAM role `iamrole_jim` is created
- [ ] Entity type is set to AWS Service
- [ ] Use case is EC2 (trust relationship with ec2.amazonaws.com)
- [ ] Policy `iampolicy_jim` is attached to the role
- [ ] All resources are created in us-east-1 region
- [ ] Role can be found in IAM console under Roles section

---

## Troubleshooting

### Issue: Policy not found
**Solution**: Ensure the policy `iampolicy_jim` exists before attaching it to the role. Create the policy if needed.

### Issue: Insufficient permissions
**Solution**: Verify that your IAM user has the necessary permissions to create roles and attach policies.

### Issue: Wrong region
**Solution**: Always verify you're working in us-east-1. Check the region selector in the console or use `--region us-east-1` in CLI commands.

### Issue: Session timeout
**Solution**: The session is valid only for 1 hour (13:44:52 - 14:44:52 UTC). Complete the task within this timeframe.

---

## Additional Notes

- The IAM role created can be attached to EC2 instances to grant them permissions defined in `iampolicy_jim`
- EC2 instances with this role can assume the permissions without needing hardcoded credentials
- This follows AWS security best practices for granting permissions to EC2 instances

---

## Quick Reference Commands

```bash
# List all IAM roles
aws iam list-roles --region us-east-1

# Get specific role details
aws iam get-role --role-name iamrole_jim --region us-east-1

# List policies attached to role
aws iam list-attached-role-policies --role-name iamrole_jim --region us-east-1

# Delete role (if needed to start over)
aws iam detach-role-policy --role-name iamrole_jim --policy-arn <policy-arn>
aws iam delete-role --role-name iamrole_jim --region us-east-1
```

---

## Completion
Once all verification steps pass, the IAM role configuration is complete and ready for use with EC2 instances.
