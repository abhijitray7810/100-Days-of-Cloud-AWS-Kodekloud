# EC2 Web Server Setup with Nginx (Nautilus DevOps)

This document outlines the steps to create an EC2 instance configured as a web server using **Nginx** for the Nautilus project.

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/11bee2d79227c1b9032076146f30925170618078/Day%2026%3A%20Configuring%20an%20EC2%20Instance%20as%20a%20Web%20Server%20with%20Nginx/Screenshot%202025-12-23%20220120.png)
## 📌 Task Overview

- **Instance Name:** datacenter-ec2  
- **Region:** us-east-1  
- **AMI:** Ubuntu (any available version)  
- **Web Server:** Nginx  
- **Access:** HTTP (Port 80) open to the internet  

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/dce34d1fc2d50b4eca4d09f739c6b5609bc43ec7/Day%2026%3A%20Configuring%20an%20EC2%20Instance%20as%20a%20Web%20Server%20with%20Nginx/Screenshot%202025-12-23%20220142.png)
## 🔐 AWS Credentials

On the **aws-client** host, retrieve credentials using:

```bash
showcreds
````

Configure AWS CLI:

```bash
aws configure
```

Enter:

* Access Key ID
* Secret Access Key
* Default region: `us-east-1`
* Output format: `json`

---

## 🚀 Step 1: Create Security Group (Allow HTTP)

```bash
aws ec2 create-security-group \
  --group-name datacenter-sg \
  --description "Allow HTTP access" \
  --region us-east-1
```

Allow inbound HTTP traffic:

```bash
aws ec2 authorize-security-group-ingress \
  --group-name datacenter-sg \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0
```

---

## 🐧 Step 2: Get Ubuntu AMI ID

```bash
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*" \
  --query "Images | sort_by(@, &CreationDate)[-1].ImageId" \
  --output text
```

---

## ⚙️ Step 3: User Data Script (Nginx Setup)

```bash
#!/bin/bash
apt update -y
apt install nginx -y
systemctl start nginx
systemctl enable nginx
```

---

## 🖥️ Step 4: Launch EC2 Instance

```bash
aws ec2 run-instances \
  --image-id <AMI_ID> \
  --instance-type t2.micro \
  --security-groups datacenter-sg \
  --user-data file://userdata.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=datacenter-ec2}]' \
  --region us-east-1
```

---

## ✅ Step 5: Verification

### Check Instance Status

```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=datacenter-ec2"
```

### Test Web Server

* Copy the **Public IPv4 Address** of the instance
* Open browser and visit:

```
http://<PUBLIC_IP>
```

You should see the **Nginx default welcome page**.

---

## 📍 Notes

* All resources are created in **us-east-1**
* Nginx is installed and started using **user data**
* HTTP access is allowed from anywhere (`0.0.0.0/0`)

---

## 🏁 Conclusion

The EC2 instance **datacenter-ec2** has been successfully deployed with Nginx configured as a web server and is accessible from the internet, fulfilling the Nautilus DevOps Team requirements.

---

**Author:** Abhijit Ray
**Role:** DevOps Engineer

```
```
