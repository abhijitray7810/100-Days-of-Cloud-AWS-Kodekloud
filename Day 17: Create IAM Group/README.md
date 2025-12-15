# AWS IAM Group Creation – iamgroup_james

This document describes how to create an IAM group named **iamgroup_james** for the Nautilus DevOps team.

## Steps

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
