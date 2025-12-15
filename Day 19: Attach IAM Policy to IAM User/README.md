# Attach IAM Policy to User – iamuser_kirsty

This document shows how to attach an existing IAM policy **iampolicy_kirsty** to an existing IAM user **iamuser_kirsty**.

## Steps
![image]()
### 1. Configure AWS CLI

Retrieve credentials using `showcreds` on the aws-client host and configure AWS CLI:

```bash
aws configure
# Default region: us-east-1
```

### 2. Get Policy ARN

Find the ARN of the policy `iampolicy_kirsty`:

```bash
aws iam list-policies --scope Local | grep iampolicy_kirsty
```

Note the **PolicyArn** from the output.

### 3. Attach Policy to User

Attach the policy to the user:

```bash
aws iam attach-user-policy \
  --user-name iamuser_kirsty \
  --policy-arn <POLICY_ARN>
```

### 4. Verify Attachment

Confirm the policy is attached to the user:

```bash
aws iam list-attached-user-policies \
  --user-name iamuser_kirsty
```

## Expected Result

* IAM User: **iamuser_kirsty**
* Attached Policy: **iampolicy_kirsty**

## Notes

* IAM is a global service; use **us-east-1** as requested.
* No additional resources are required for this task.
