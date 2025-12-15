# AWS IAM User Creation – iamuser_mark

This document outlines the steps to create an IAM user named **iamuser_mark** in the AWS account for the Nautilus DevOps team.

## Prerequisites

* Access to the **aws-client** host
* Valid AWS credentials (retrieve using `showcreds` on the aws-client host)
* AWS CLI installed and configured

> Note: IAM is a global service; however, use **us-east-1** as specified when configuring AWS CLI.

## Steps
![image]()
### 1. Configure AWS CLI

Configure the AWS CLI with the provided credentials:

```bash
aws configure
# Default region name: us-east-1
```

### 2. Create IAM User

Create the IAM user named `iamuser_mark`:

```bash
aws iam create-user \
  --user-name iamuser_mark
```

### 3. Verify IAM User Creation

Confirm that the user has been created successfully:

```bash
aws iam list-users | grep iamuser_mark
```

Alternatively, you can describe the user directly:

```bash
aws iam get-user \
  --user-name iamuser_mark
```

## Expected Result

* IAM User Name: **iamuser_mark**
* User Status: **Active**

## Notes

* No policies, groups, or access keys are required unless specified.
* Ensure only the requested IAM user is created before submitting the task.
