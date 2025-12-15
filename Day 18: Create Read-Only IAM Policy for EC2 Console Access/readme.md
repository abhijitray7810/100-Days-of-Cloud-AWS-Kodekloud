# AWS IAM Policy Creation – iampolicy_ravi

This document explains how to create an IAM policy named **iampolicy_ravi** that provides **read-only access to Amazon EC2** resources.

## Steps
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/674b585f880674baa9dd173e1676cebdb9f1fc33/Day%2018%3A%20Create%20Read-Only%20IAM%20Policy%20for%20EC2%20Console%20Access/Screenshot%202025-12-16%20005840.png)
### 1. Configure AWS CLI

Retrieve credentials using `showcreds` on the aws-client host and configure AWS CLI:

```bash
aws configure
# Default region: us-east-1
```

### 2. Create Policy Document

Create a JSON file named `ec2-readonly.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
```

### 3. Create IAM Policy

Create the IAM policy using the JSON document:

```bash
aws iam create-policy \
  --policy-name iampolicy_ravi \
  --policy-document file://ec2-readonly.json
```

### 4. Verify Policy Creation

Confirm the policy exists:

```bash
aws iam list-policies --scope Local | grep iampolicy_ravi
```

## Expected Result

* IAM Policy Name: **iampolicy_ravi**
* Permissions: Read-only access to EC2 (instances, AMIs, snapshots)

## Notes

* IAM is a global service, but configure AWS CLI with **us-east-1** as requested.
* No attachment to users or groups is required for this task.
