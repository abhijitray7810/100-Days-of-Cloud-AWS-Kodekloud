# AWS ECR & ECS Containerized Application Deployment

![AWS](https://img.shields.io/badge/AWS-ECS%20%7C%20ECR-orange?style=for-the-badge&logo=amazon-aws)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)

A comprehensive guide to deploying containerized applications using Amazon Elastic Container Registry (ECR) and Amazon Elastic Container Service (ECS) with AWS Fargate.
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/77b03a64c502a429460900f97e6f524c9f70ea78/Day%2038%3A%20Deploying%20Containerized%20Applications%20with%20Amazon%20ECS/Screenshot%202026-01-22%20184933.png)
## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Step-by-Step Implementation](#step-by-step-implementation)
- [Configuration Details](#configuration-details)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Security Best Practices](#security-best-practices)
- [Cleanup](#cleanup)
- [Additional Resources](#additional-resources)
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/77b03a64c502a429460900f97e6f524c9f70ea78/Day%2038%3A%20Deploying%20Containerized%20Applications%20with%20Amazon%20ECS/Screenshot%202026-01-22%20185625.png)
## 🎯 Overview

This project demonstrates how to:
- Create a private Amazon ECR repository for Docker images
- Build and push a Docker image to ECR
- Set up an Amazon ECS cluster using AWS Fargate
- Deploy a containerized application using ECS task definitions
- Access the deployed application via a public endpoint
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/77b03a64c502a429460900f97e6f524c9f70ea78/Day%2038%3A%20Deploying%20Containerized%20Applications%20with%20Amazon%20ECS/Screenshot%202026-01-22%20191324.png)
### Use Cases
- Microservices deployment
- CI/CD pipeline integration
- Scalable containerized applications
- Multi-environment deployments
- Blue-green deployment strategies

## 🏗️ Architecture

```
┌─────────────┐      ┌──────────────┐      ┌─────────────────┐
│             │      │              │      │                 │
│  Developer  │─────▶│  Dockerfile  │─────▶│  Docker Build   │
│             │      │              │      │                 │
└─────────────┘      └──────────────┘      └────────┬────────┘
                                                     │
                                                     ▼
                     ┌──────────────────────────────────────┐
                     │   Amazon ECR Repository              │
                     │   (Private Container Registry)       │
                     │   devops-ecr                         │
                     └───────────────┬──────────────────────┘
                                     │
                                     ▼
                     ┌──────────────────────────────────────┐
                     │   ECS Task Definition                │
                     │   - Container Specs                  │
                     │   - Resource Allocation              │
                     │   - Network Configuration            │
                     └───────────────┬──────────────────────┘
                                     │
                                     ▼
                     ┌──────────────────────────────────────┐
                     │   ECS Cluster (devops-cluster)       │
                     │   AWS Fargate Launch Type            │
                     └───────────────┬──────────────────────┘
                                     │
                                     ▼
                     ┌──────────────────────────────────────┐
                     │   Running Container Tasks            │
                     │   Public IP: 44.222.205.145          │
                     └───────────────┬──────────────────────┘
                                     │
                                     ▼
                     ┌──────────────────────────────────────┐
                     │   Application Accessible             │
                     │   "Welcome to KKE AWS cloud labs!"   │
                     └──────────────────────────────────────┘
```

## ✅ Prerequisites

- AWS Account with appropriate IAM permissions
- AWS CLI installed and configured
- Docker installed locally
- Basic understanding of containerization
- Git (for cloning this repository)
![image]()
### Required IAM Permissions
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*",
        "ecs:*",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "iam:PassRole",
        "cloudformation:*"
      ],
      "Resource": "*"
    }
  ]
}
```
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/77b03a64c502a429460900f97e6f524c9f70ea78/Day%2038%3A%20Deploying%20Containerized%20Applications%20with%20Amazon%20ECS/Screenshot%202026-01-22%20191607.png)
## 📁 Project Structure

```
aws-ecs-ecr-deployment/
├── README.md
├── Dockerfile
├── index.html
├── cloudformation/
│   └── ecs-cluster.yaml
├── task-definition/
│   └── devops-taskdefinition.json
├── scripts/
│   ├── build-and-push.sh
│   ├── deploy.sh
│   └── cleanup.sh
└── screenshots/
    ├── ecr-repository.png
    ├── docker-build.png
    ├── ecs-cluster.png
    └── deployed-app.png
```

## 🚀 Step-by-Step Implementation
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/77b03a64c502a429460900f97e6f524c9f70ea78/Day%2038%3A%20Deploying%20Containerized%20Applications%20with%20Amazon%20ECS/Screenshot%202026-01-22%20191913.png)
### Step 1: Create ECR Repository

**Using AWS Console:**
1. Navigate to Amazon ECR
2. Click "Create repository"
3. Repository name: `devops-ecr`
4. Tag immutability: Disabled (Mutable)
5. Scan on push: Enabled (recommended)
6. Encryption: AES-256
7. Click "Create repository"

**Using AWS CLI:**
```bash
# Create ECR repository
aws ecr create-repository \
    --repository-name devops-ecr \
    --region us-east-1 \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=AES256

# Get repository URI
aws ecr describe-repositories \
    --repository-names devops-ecr \
    --query 'repositories[0].repositoryUri' \
    --output text
```

**Expected Output:**
```
954973595150.dkr.ecr.us-east-1.amazonaws.com/devops-ecr
```

### Step 2: Create Dockerfile

Create a `Dockerfile` in your project directory:

```dockerfile
# Use nginx alpine as base image
FROM nginx:alpine

# Copy custom HTML file
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
```

Create `index.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KKE AWS Cloud Labs</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        h1 {
            color: white;
            font-size: 3em;
            text-align: center;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
    </style>
</head>
<body>
    <h1>Welcome to KKE AWS cloud labs!</h1>
</body>
</html>
```

### Step 3: Build and Push Docker Image
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/b0a25da5ad6fd56fc1acf08d03113581cbbc1e34/Day%2038%3A%20Deploying%20Containerized%20Applications%20with%20Amazon%20ECS/Screenshot%202026-01-22%20192022.png)
**Build the Docker image:**
```bash
# Navigate to project directory
cd /root/pyapp

# Build Docker image
docker build -t 954973595150.dkr.ecr.us-east-1.amazonaws.com/devops-ecr:latest .
```

**Expected Output:**
```
Step 1/4 : FROM nginx:alpine
 ---> 1074353eec8d
Step 2/4 : COPY index.html /usr/share/nginx/html/index.html
 ---> 5cfa459df086
Step 3/4 : EXPOSE 80
 ---> Running in 709e2b51ebe0
Step 4/4 : CMD ["nginx", "-g", "daemon off;"]
 ---> 9d4c3dd22983
Successfully built 9d4c3dd22983
Successfully tagged 954973595150.dkr.ecr.us-east-1.amazonaws.com/devops-ecr:latest
```

**Authenticate Docker with ECR:**
```bash
# Get ECR login password and authenticate
aws ecr get-login-password --region us-east-1 | \
    docker login --username AWS --password-stdin \
    954973595150.dkr.ecr.us-east-1.amazonaws.com
```

**Expected Output:**
```
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning.

Login Succeeded
```

**Push image to ECR:**
```bash
# Push Docker image to ECR
docker push 954973595150.dkr.ecr.us-east-1.amazonaws.com/devops-ecr:latest
```

**Expected Output:**
```
The push refers to repository [954973595150.dkr.ecr.us-east-1.amazonaws.com/devops-ecr]
5402ba3adc77: Pushed
4b6d03d0cebb: Pushed
67ea0b046e7d: Pushed
ed5fa8595c7a: Pushed
latest: digest: sha256:429545d95e693c2f8886a3f3458dc9b4147597a3a361e874c127b41abce5494b size: 2196
```

### Step 4: Create ECS Cluster
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/b0a25da5ad6fd56fc1acf08d03113581cbbc1e34/Day%2038%3A%20Deploying%20Containerized%20Applications%20with%20Amazon%20ECS/Screenshot%202026-01-22%20192650.png)
**Using AWS Console:**
1. Navigate to Amazon ECS
2. Click "Create Cluster"
3. Cluster name: `devops-cluster`
4. Infrastructure: AWS Fargate (serverless)
5. Click "Create"

**Using CloudFormation:**

Create `cloudformation/ecs-cluster.yaml`:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'ECS Cluster for DevOps Application'

Resources:
  ECSCluster:
    Type: 'AWS::ECS::Cluster'
    Properties:
      ClusterName: devops-cluster
      ClusterSettings:
        - Name: containerInsights
          Value: enabled
      Tags:
        - Key: Name
          Value: devops-cluster
        - Key: Environment
          Value: production
        - Key: ManagedBy
          Value: CloudFormation

Outputs:
  ECSCluster:
    Description: The created cluster
    Value: !Ref ECSCluster
    Export:
      Name: devops-cluster
```

**Deploy CloudFormation stack:**
```bash
aws cloudformation create-stack \
    --stack-name Infra-ECS-Cluster-devops-cluster \
    --template-body file://cloudformation/ecs-cluster.yaml \
    --region us-east-1
```

### Step 5: Create Task Definition
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/0a8b70780dcb99ce1c983fdb9b5d882b73c8acfe/Day%2038%3A%20Deploying%20Containerized%20Applications%20with%20Amazon%20ECS/Screenshot%202026-01-22%20192706.png)
**Using AWS Console:**
1. Navigate to ECS → Task Definitions
2. Click "Create new task definition"
3. Task definition family: `devops-taskdefinition`
4. Launch type: AWS Fargate
5. Operating system: Linux/x86_64
6. Task size:
   - CPU: 1 vCPU (1024 units)
   - Memory: 3 GB (3072 MiB)
7. Container configuration:
   - Name: `pyapp`
   - Image URI: `954973595150.dkr.ecr.us-east-1.amazonaws.com/devops-ecr:latest`
   - Port mappings: 80 (TCP), HTTP
8. Task execution role: `ecsTaskExecutionRole`
9. Click "Create"

**Task Definition JSON:**

Create `task-definition/devops-taskdefinition.json`:

```json
{
  "family": "devops-taskdefinition",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "1024",
  "memory": "3072",
  "executionRoleArn": "arn:aws:iam::954973595150:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "pyapp",
      "image": "954973595150.dkr.ecr.us-east-1.amazonaws.com/devops-ecr:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp",
          "appProtocol": "http"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/devops-taskdefinition",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

**Register task definition:**
```bash
aws ecs register-task-definition \
    --cli-input-json file://task-definition/devops-taskdefinition.json
```

### Step 6: Create and Run ECS Service
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/0a8b70780dcb99ce1c983fdb9b5d882b73c8acfe/Day%2038%3A%20Deploying%20Containerized%20Applications%20with%20Amazon%20ECS/Screenshot%202026-01-22%20192749.png)
**Using AWS Console:**
1. Navigate to your ECS cluster
2. Click "Create" under Services
3. Launch type: Fargate
4. Task definition: `devops-taskdefinition:1`
5. Service name: `devops-service`
6. Number of tasks: 1
7. Network configuration:
   - VPC: Default VPC
   - Subnets: Select public subnets
   - Security group: Allow HTTP (port 80)
   - Auto-assign public IP: ENABLED
8. Click "Create service"

**Using AWS CLI:**
```bash
# Get default VPC
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=isDefault,Values=true" \
    --query 'Vpcs[0].VpcId' \
    --output text)

# Get public subnets
SUBNET_IDS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'Subnets[*].SubnetId' \
    --output text)

# Create security group
SG_ID=$(aws ec2 create-security-group \
    --group-name devops-ecs-sg \
    --description "Security group for ECS tasks" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

# Allow HTTP traffic
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# Create ECS service
aws ecs create-service \
    --cluster devops-cluster \
    --service-name devops-service \
    --task-definition devops-taskdefinition:1 \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_IDS],securityGroups=[$SG_ID],assignPublicIp=ENABLED}"
```

### Step 7: Verify Deployment
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/0a8b70780dcb99ce1c983fdb9b5d882b73c8acfe/Day%2038%3A%20Deploying%20Containerized%20Applications%20with%20Amazon%20ECS/Screenshot%202026-01-22%20192830.png)
**Get task public IP:**
```bash
# List tasks
TASK_ARN=$(aws ecs list-tasks \
    --cluster devops-cluster \
    --service-name devops-service \
    --query 'taskArns[0]' \
    --output text)

# Get task details
aws ecs describe-tasks \
    --cluster devops-cluster \
    --tasks $TASK_ARN \
    --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' \
    --output text

# Get public IP from network interface
ENI_ID=$(aws ecs describe-tasks \
    --cluster devops-cluster \
    --tasks $TASK_ARN \
    --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' \
    --output text)

PUBLIC_IP=$(aws ec2 describe-network-interfaces \
    --network-interface-ids $ENI_ID \
    --query 'NetworkInterfaces[0].Association.PublicIp' \
    --output text)

echo "Application URL: http://$PUBLIC_IP"
```

**Access the application:**
```bash
# Test with curl
curl http://44.222.205.145

# Or open in browser
http://44.222.205.145
```

**Expected Output:**
```
Welcome to KKE AWS cloud labs!
```

## 📊 Configuration Details
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/0a8b70780dcb99ce1c983fdb9b5d882b73c8acfe/Day%2038%3A%20Deploying%20Containerized%20Applications%20with%20Amazon%20ECS/Screenshot%202026-01-22%20190403.png)
### ECR Repository Details
- **Name:** devops-ecr
- **URI:** 954973595150.dkr.ecr.us-east-1.amazonaws.com/devops-ecr
- **Region:** us-east-1
- **Encryption:** AES-256
- **Tag Immutability:** Mutable
- **Image Scanning:** Enabled

### Docker Image Details
- **Base Image:** nginx:alpine
- **Image Size:** 25.91 MB
- **Tag:** latest
- **Digest:** sha256:429545d95e693c2f8886a3f3458dc9b4147597a3a361e874c127b41abce5494b

### ECS Cluster Configuration
- **Cluster Name:** devops-cluster
- **Launch Type:** AWS Fargate (Serverless)
- **ARN:** arn:aws:ecs:us-east-1:954973595150:cluster/devops-cluster
- **Status:** ACTIVE
- **Container Insights:** Enabled

### Task Definition Specifications
- **Family:** devops-taskdefinition
- **Revision:** 1
- **CPU:** 1024 units (1 vCPU)
- **Memory:** 3072 MiB (3 GB)
- **Network Mode:** awsvpc
- **Operating System:** Linux/x86_64
- **Architecture:** x86_64

### Container Configuration
- **Container Name:** pyapp
- **Port:** 80 (TCP/HTTP)
- **Essential:** Yes
- **Log Driver:** awslogs

## ✔️ Verification

### Check ECR Image
```bash
# List images in repository
aws ecr list-images \
    --repository-name devops-ecr \
    --region us-east-1

# Describe image
aws ecr describe-images \
    --repository-name devops-ecr \
    --image-ids imageTag=latest \
    --region us-east-1
```

### Check ECS Cluster
```bash
# Describe cluster
aws ecs describe-clusters \
    --clusters devops-cluster \
    --region us-east-1

# List services
aws ecs list-services \
    --cluster devops-cluster \
    --region us-east-1
```

### Check Running Tasks
```bash
# List tasks
aws ecs list-tasks \
    --cluster devops-cluster \
    --region us-east-1

# Describe task
aws ecs describe-tasks \
    --cluster devops-cluster \
    --tasks <TASK_ARN> \
    --region us-east-1
```

### Health Check
```bash
# Check application response
curl -I http://<PUBLIC_IP>

# Expected: HTTP/1.1 200 OK
```

## 🔧 Troubleshooting
### Issue 1: Docker Login Fails
```bash
# Error: Cannot perform an interactive login from a non TTY device

# Solution: Use pipe instead of interactive mode
aws ecr get-login-password --region us-east-1 | \
    docker login --username AWS --password-stdin \
    954973595150.dkr.ecr.us-east-1.amazonaws.com
```

### Issue 2: Task Fails to Start
```bash
# Check task stopped reason
aws ecs describe-tasks \
    --cluster devops-cluster \
    --tasks <TASK_ARN> \
    --query 'tasks[0].stoppedReason'

# Common causes:
# - Insufficient permissions for task execution role
# - Invalid image URI
# - Resource limits exceeded
```

### Issue 3: Cannot Access Application
```bash
# Check security group rules
aws ec2 describe-security-groups \
    --group-ids <SG_ID>

# Ensure port 80 is open
# Ensure public IP is assigned
# Check task is in RUNNING state
```

### Issue 4: Image Pull Error
```bash
# Verify task execution role has ECR permissions
# Attach AmazonECSTaskExecutionRolePolicy

aws iam attach-role-policy \
    --role-name ecsTaskExecutionRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

## 🔒 Security Best Practices

### 1. ECR Security
- ✅ Enable image scanning on push
- ✅ Use private repositories
- ✅ Implement lifecycle policies to remove old images
- ✅ Enable encryption at rest (AES-256 or KMS)
- ✅ Use IAM policies for access control

### 2. ECS Security
- ✅ Use task execution roles with minimal permissions
- ✅ Enable Container Insights for monitoring
- ✅ Use security groups to restrict network access
- ✅ Enable VPC Flow Logs
- ✅ Use AWS Secrets Manager for sensitive data

### 3. Network Security
```bash
# Security group should allow only necessary ports
# Example: Allow HTTP only from specific IPs
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 203.0.113.0/24  # Your IP range
```

### 4. Least Privilege IAM
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Resource": "arn:aws:ecr:us-east-1:954973595150:repository/devops-ecr"
    }
  ]
}
```

## 🧹 Cleanup

To avoid incurring charges, clean up all resources:

### Delete ECS Service
```bash
# Update service to 0 tasks
aws ecs update-service \
    --cluster devops-cluster \
    --service devops-service \
    --desired-count 0

# Delete service
aws ecs delete-service \
    --cluster devops-cluster \
    --service devops-service \
    --force
```

### Delete ECS Cluster
```bash
aws ecs delete-cluster \
    --cluster devops-cluster
```

### Delete Task Definition
```bash
# Deregister all revisions
aws ecs deregister-task-definition \
    --task-definition devops-taskdefinition:1
```

### Delete ECR Images and Repository
```bash
# Delete all images
aws ecr batch-delete-image \
    --repository-name devops-ecr \
    --image-ids imageTag=latest

# Delete repository
aws ecr delete-repository \
    --repository-name devops-ecr \
    --force
```

### Delete CloudFormation Stack
```bash
aws cloudformation delete-stack \
    --stack-name Infra-ECS-Cluster-devops-cluster
```

### Delete Security Group
```bash
aws ec2 delete-security-group \
    --group-id $SG_ID
```

### Complete Cleanup Script
```bash
#!/bin/bash
# cleanup.sh

# Delete ECS service
aws ecs update-service --cluster devops-cluster --service devops-service --desired-count 0
aws ecs delete-service --cluster devops-cluster --service devops-service --force

# Delete ECS cluster
aws ecs delete-cluster --cluster devops-cluster

# Delete task definition
aws ecs deregister-task-definition --task-definition devops-taskdefinition:1

# Delete ECR repository
aws ecr delete-repository --repository-name devops-ecr --force

# Delete CloudFormation stack
aws cloudformation delete-stack --stack-name Infra-ECS-Cluster-devops-cluster

echo "Cleanup complete!"
```

## 📚 Additional Resources

### Official Documentation
- [Amazon ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [Amazon ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [AWS Fargate Documentation](https://docs.aws.amazon.com/fargate/)
- [Docker Documentation](https://docs.docker.com/)

### Tutorials and Guides
- [ECS Task Definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html)
- [ECR Lifecycle Policies](https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html)
- [ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/intro.html)

### Cost Optimization
- Use Fargate Spot for non-critical workloads
- Implement ECR lifecycle policies
- Right-size task CPU and memory
- Use AWS Cost Explorer to monitor spending

## 🎓 Learning Outcomes

After completing this project, you will understand:
- ✅ Container registry management with ECR
- ✅ Docker image building and deployment
- ✅ Container orchestration with ECS
- ✅ Serverless container deployment with Fargate
- ✅ Task definitions and service configuration
- ✅ Network and security configuration for containers
- ✅ Infrastructure as Code with CloudFormation
- ✅ AWS CLI automation

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**DevOps 365 Days Challenge**
- Day: 118
- Topic: AWS ECR & ECS Deployment
- Date: January 22, 2026

## 🌟 Acknowledgments

- AWS Documentation Team
- Docker Community
- DevOps Community

---

**Happy Containerizing! 🐳☁️**

If you found this helpful, please ⭐ star this repository!
