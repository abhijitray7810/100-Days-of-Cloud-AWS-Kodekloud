# AWS IAM User Creation – iamuser_mark

This document outlines the steps to create an IAM user named **iamuser_mark** in the AWS account for the Nautilus DevOps team.

## Prerequisites

* Access to the **aws-client** host
* Valid AWS credentials (retrieve using `showcreds` on the aws-client host)
* AWS CLI installed and configured

> Note: IAM is a global service; however, use **us-east-1** as specified when configuring AWS CLI.

## Steps
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/3f264baa9df5a769a1fc1f13d8e9cf1dea580eb1/Day%2016%3A%20Create%20IAM%20User/Screenshot%202025-12-16%20003612.png)
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
