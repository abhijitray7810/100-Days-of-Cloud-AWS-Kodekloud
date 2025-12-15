# AWS EBS Snapshot Creation – datacenter-vol
![image]()
This document describes the steps to create an Amazon EBS snapshot for an existing volume named **datacenter-vol** in the **us-east-1** region, as requested by the Nautilus DevOps team.

## Prerequisites

* Access to the **aws-client** host
* Valid AWS credentials (retrieve using `showcreds` on the aws-client host)
* AWS CLI configured to use **us-east-1** region

## Steps

### 1. Configure AWS CLI

Ensure the AWS CLI is configured with the provided credentials and correct region:

```bash
aws configure
# Region: us-east-1
```

### 2. Identify the Volume ID

Find the volume ID for the volume named `datacenter-vol`:

```bash
aws ec2 describe-volumes \
  --filters Name=tag:Name,Values=datacenter-vol \
  --region us-east-1
```

Note the **VolumeId** from the output.

### 3. Create the Snapshot

Create a snapshot with the required name and description:

```bash
aws ec2 create-snapshot \
  --volume-id <VOLUME_ID> \
  --description "datacenter Snapshot" \
  --tag-specifications 'ResourceType=snapshot,Tags=[{Key=Name,Value=datacenter-vol-ss}]' \
  --region us-east-1
```

Record the **SnapshotId** from the output.

### 4. Verify Snapshot Completion

Wait until the snapshot status becomes **completed**:

```bash
aws ec2 describe-snapshots \
  --snapshot-ids <SNAPSHOT_ID> \
  --region us-east-1
```

Ensure the `State` shows **completed** before submitting the task.

## Expected Result

* Snapshot Name: **datacenter-vol-ss**
* Description: **datacenter Snapshot**
* Region: **us-east-1**
* Status: **completed**

## Notes

* Do not create resources in any region other than **us-east-1**.
* Ensure snapshot completion before task submission.
