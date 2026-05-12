# AWS Secure Log Aggregation Architecture

This project demonstrates a secure and scalable log aggregation pipeline in AWS using VPC Peering, EC2, IAM Roles, Cron Jobs, and Amazon S3.

---

# Architecture Overview

- Private EC2 instance generates logs.
- Logs are securely transferred to a Public EC2 instance through VPC Peering.
- Public EC2 uploads logs to a private Amazon S3 bucket.
- IAM Role is used for secure S3 access.
- Cron jobs automate log transfer and upload.

---

# AWS Services Used

- Amazon VPC
- VPC Peering
- Amazon EC2
- IAM Role
- Amazon S3
- Route Tables
- Internet Gateway
- Cron Jobs
- SCP

---

# Infrastructure Setup

## Existing Resources

### Private VPC Environment

| Resource | Name |
|---|---|
| VPC | datacenter-priv-vpc |
| Subnet | datacenter-priv-subnet |
| Route Table | datacenter-priv-rt |
| EC2 Instance | datacenter-priv-ec2 |

---

## Created Resources

### Public VPC Environment

| Resource | Name |
|---|---|
| VPC | datacenter-pub-vpc |
| Subnet | datacenter-pub-subnet |
| Route Table | datacenter-pub-rt |
| EC2 Instance | datacenter-pub-ec2 |
| Internet Gateway | datacenter-pub-igw |

---

# S3 Configuration

| Resource | Value |
|---|---|
| Bucket Name | datacenter-s3-logs-20934 |
| Object Path | datacenter-priv-vpc/boot/boots.log |

---

# IAM Configuration

## IAM Role

```bash
datacenter-s3-role
````

## Attached Policy

```bash
AmazonS3FullAccess
```

## Instance Profile

```bash
datacenter-s3-profile
```

---

# VPC Peering

## Peering Connection

```bash
datacenter-vpc-peering
```

## Route Configuration

### Private Route Table

```text
Destination: 10.20.0.0/16
Target: VPC Peering Connection
```

### Public Route Table

```text
Destination: 10.10.0.0/16
Target: VPC Peering Connection
```

---

# Log Transfer Workflow

## Step 1: Private EC2 → Public EC2

A cron job on the private EC2 transfers:

```bash
/var/log/boots.log
```

to:

```bash
/home/ubuntu/boots.log
```

on the public EC2 using SCP.

### Transfer Script

```bash
#!/bin/bash
scp -i /home/ubuntu/.ssh/datacenter-key.pem \
-o StrictHostKeyChecking=no \
/var/log/boots.log \
ubuntu@10.20.1.118:/home/ubuntu/boots.log
```

---

## Step 2: Public EC2 → Amazon S3

A cron job on the public EC2 uploads logs to S3.

### Upload Script

```bash
#!/bin/bash
aws s3 cp /home/ubuntu/boots.log \
s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/boots.log
```

---

# Cron Job Configuration

## Private EC2 Cron

```bash
*/5 * * * * /home/ubuntu/send-log.sh
```

## Public EC2 Cron

```bash
*/5 * * * * /usr/local/bin/upload-to-s3.sh
```

---

# Verification

## Verify S3 Upload

```bash
aws s3 ls s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/
```

Expected Output:

```bash
boots.log
```

---

# Security Features

* Private EC2 has no internet access.
* Communication occurs via VPC Peering.
* S3 access uses IAM Role instead of static credentials.
* S3 bucket blocks all public access.
* SSH key authentication used for secure transfers.

---

# Project Outcome

Successfully implemented a secure AWS log aggregation system where:

* Logs are generated in a private VPC.
* Logs are securely transferred to a public VPC.
* Logs are automatically uploaded to Amazon S3.
* Full automation is achieved using cron jobs.

---

# Author

Abhijit Ray

DevOps | Cloud | AWS | Linux | Terraform | Docker | Kubernetes

```
```
