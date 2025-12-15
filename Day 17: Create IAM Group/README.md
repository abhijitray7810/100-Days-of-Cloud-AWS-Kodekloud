# AWS IAM Group Creation – iamgroup_james

This document describes how to create an IAM group named **iamgroup_james** for the Nautilus DevOps team.

## Steps
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/ce21898007a56abe06c6723d68f000a1cb81cc43/Day%2017%3A%20Create%20IAM%20Group/Screenshot%202025-12-16%20004220.png)
### 1. Configure AWS CLI

Retrieve credentials using `showcreds` on the aws-client host and configure AWS CLI:

```bash
aws configure
# Default region: us-east-1
```

### 2. Create IAM Group

Create the IAM group:

```bash
aws iam create-group \
  --group-name iamgroup_james
```

### 3. Verify Group Creation

Confirm the group exists:

```bash
aws iam get-group \
  --group-name iamgroup_james
```

## Expected Result

* IAM Group Name: **iamgroup_james**
* Status: Successfully created

## Notes

* IAM is a global service, but use **us-east-1** as requested.
* No users or policies are required for this task.
