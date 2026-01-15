# AWS RDS MySQL Setup Guide for Nautilus DevOps Team
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/8576c0da212851ea1b93c87119af58643f8ada87/Day%2035%3A%20Deploying%20and%20Managing%20Applications%20on%20AWS/Screenshot%202026-01-15%20172810.png)
## Overview
This guide provides step-by-step instructions to set up a private RDS MySQL instance and configure EC2 connectivity for the Nautilus DevOps team's application.

## AWS Credentials
```
Console URL: https://800539853898.signin.aws.amazon.com/console?region=us-east-1
Username: kk_labs_user_123180
Password: pA^izxB0Csye
Region: us-east-1
Session: Thu Jan 15 11:18:47 UTC 2026 - Thu Jan 15 12:18:47 UTC 2026
```

**Note**: Credentials can be retrieved using `showcreds` command on aws-client host.
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/8576c0da212851ea1b93c87119af58643f8ada87/Day%2035%3A%20Deploying%20and%20Managing%20Applications%20on%20AWS/Screenshot%202026-01-15%20172750.png)
## Task Requirements

### 1. RDS Instance Configuration
- **Instance Name**: datacenter-rds
- **Template**: Sandbox (Free tier)
- **Engine**: MySQL v8.4.5
- **Instance Type**: db.t3.micro
- **Master Username**: datacenter_admin
- **Master Password**: (Choose a strong password)
- **Storage Type**: gp2 (General Purpose SSD)
- **Storage Size**: 5 GiB
- **Initial Database**: datacenter_db
- **Status**: Must be in "available" state

### 2. EC2 Instance
- **Instance Name**: datacenter-ec2 (pre-existing)
- **Required Ports**: 
  - Port 3306 (MySQL)
  - Port 80 (HTTP)

## Step-by-Step Implementation
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/8576c0da212851ea1b93c87119af58643f8ada87/Day%2035%3A%20Deploying%20and%20Managing%20Applications%20on%20AWS/Screenshot%202026-01-15%20172736.png)
### Step 1: Create RDS Instance

1. **Login to AWS Console**
   - Navigate to: https://800539853898.signin.aws.amazon.com/console?region=us-east-1
   - Use the provided credentials
   - Ensure you're in the **us-east-1** region

2. **Navigate to RDS Service**
   - Search for "RDS" in the AWS Console
   - Click on "RDS" to open the service

3. **Create Database**
   - Click "Create database"
   - Choose **Standard create** method
   - Select **MySQL** as engine type
   - Select **MySQL 8.4.5** as the version

4. **Templates**
   - Select **Free tier** (Sandbox template)

5. **Settings**
   - **DB instance identifier**: `datacenter-rds`
   - **Master username**: `datacenter_admin`
   - **Master password**: Choose a strong password (e.g., `DataCenter@2026!`)
   - Confirm password

6. **Instance Configuration**
   - **DB instance class**: Burstable classes - db.t3.micro

7. **Storage**
   - **Storage type**: General Purpose SSD (gp2)
   - **Allocated storage**: 5 GiB
   - Uncheck "Enable storage autoscaling" (optional)

8. **Connectivity**
   - **Virtual Private Cloud (VPC)**: Use default VPC
   - **Public access**: No (keep private)
   - **VPC security group**: Create new or use existing
   - Note down the security group name

9. **Additional Configuration**
   - Expand "Additional configuration"
   - **Initial database name**: `datacenter_db`
   - Keep other settings as default

10. **Create Database**
    - Review all settings
    - Click "Create database"
    - Wait for status to change to "Available" (this may take 5-10 minutes)

### Step 2: Configure Security Groups

1. **Get RDS Security Group**
   - Go to RDS Console → Databases → datacenter-rds
   - Click on the "Connectivity & security" tab
   - Note the VPC security group ID

2. **Get EC2 Instance Details**
   - Go to EC2 Console → Instances
   - Find `datacenter-ec2` instance
   - Note down:
     - Instance ID
     - Security Group ID
     - Private IP address

3. **Update RDS Security Group**
   - Go to EC2 Console → Security Groups
   - Find the RDS security group
   - Edit inbound rules:
     - **Type**: MySQL/Aurora
     - **Protocol**: TCP
     - **Port**: 3306
     - **Source**: Security group of datacenter-ec2 instance
     - **Description**: Allow MySQL from datacenter-ec2
   - Save rules

4. **Update EC2 Security Group**
   - Find the EC2 security group
   - Edit inbound rules to ensure:
     - **Type**: HTTP
     - **Protocol**: TCP
     - **Port**: 80
     - **Source**: 0.0.0.0/0
     - **Description**: Allow HTTP traffic
     - 
     - **Type**: SSH
     - **Protocol**: TCP
     - **Port**: 22
     - **Source**: Your IP or 0.0.0.0/0
     - **Description**: Allow SSH access
   - Save rules

### Step 3: Setup SSH Key for EC2 Access
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/8576c0da212851ea1b93c87119af58643f8ada87/Day%2035%3A%20Deploying%20and%20Managing%20Applications%20on%20AWS/Screenshot%202026-01-15%20172716.png)
**On aws-client host:**

1. **Check if SSH key exists**
   ```bash
   ls -la /root/.ssh/id_rsa
   ```

2. **Create SSH key if not exists**
   ```bash
   ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa -N ""
   ```

3. **Display public key**
   ```bash
   cat /root/.ssh/id_rsa.pub
   ```
   - Copy the entire output

4. **Connect to EC2 via AWS Console**
   - Go to EC2 Console → Instances
   - Select `datacenter-ec2`
   - Click "Connect" → "Session Manager" or "EC2 Instance Connect"

5. **Add public key to EC2 instance**
   
   Once connected to the EC2 instance:
   ```bash
   # Switch to root user (if needed)
   sudo su -
   
   # Create .ssh directory if not exists
   mkdir -p /root/.ssh
   chmod 700 /root/.ssh
   
   # Add your public key
   echo "YOUR_PUBLIC_KEY_HERE" >> /root/.ssh/authorized_keys
   
   # Set correct permissions
   chmod 600 /root/.ssh/authorized_keys
   ```

6. **Test SSH connection from aws-client**
   ```bash
   # Replace with actual public IP
   ssh -i /root/.ssh/id_rsa root@<EC2_PUBLIC_IP>
   ```

### Step 4: Configure PHP Application

1. **Get RDS Endpoint**
   - Go to RDS Console → Databases → datacenter-rds
   - Copy the "Endpoint" from the "Connectivity & security" tab
   - Example: `datacenter-rds.xxxxxxxxxx.us-east-1.rds.amazonaws.com`

2. **Review index.php file**
   
   On aws-client host:
   ```bash
   cat /root/index.php
   ```

3. **Edit index.php with RDS details**
   ```bash
   vi /root/index.php
   ```
   
   Update the following variables:
   ```php
   <?php
   $servername = "datacenter-rds.xxxxxxxxxx.us-east-1.rds.amazonaws.com";
   $username = "datacenter_admin";
   $password = "DataCenter@2026!";  // Your RDS password
   $dbname = "datacenter_db";
   
   // Create connection
   $conn = new mysqli($servername, $username, $password, $dbname);
   
   // Check connection
   if ($conn->connect_error) {
       die("Connection failed: " . $conn->connect_error);
   }
   echo "Connected successfully";
   ?>
   ```

4. **Copy index.php to EC2 instance**
   ```bash
   # Copy file to EC2
   scp -i /root/.ssh/id_rsa /root/index.php root@<EC2_PUBLIC_IP>:/var/www/html/
   ```

5. **Verify file on EC2**
   
   SSH into EC2:
   ```bash
   ssh -i /root/.ssh/id_rsa root@<EC2_PUBLIC_IP>
   ```
   
   Check the file:
   ```bash
   ls -la /var/www/html/index.php
   cat /var/www/html/index.php
   ```

6. **Ensure Apache/PHP is running**
   ```bash
   # Check if httpd/apache is running
   systemctl status httpd
   # Or for Ubuntu/Debian
   systemctl status apache2
   
   # Start if not running
   systemctl start httpd
   # Or
   systemctl start apache2
   
   # Enable on boot
   systemctl enable httpd
   ```

### Step 5: Verification
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/8576c0da212851ea1b93c87119af58643f8ada87/Day%2035%3A%20Deploying%20and%20Managing%20Applications%20on%20AWS/Screenshot%202026-01-15%20172654.png)
1. **Access the Application**
   - Open a web browser
   - Navigate to: `http://<EC2_PUBLIC_IP>/index.php`
   - You should see: **"Connected successfully"**

2. **Troubleshooting**
   
   If connection fails:
   
   a. **Check RDS Status**
   ```bash
   # Ensure RDS is in "Available" state
   ```
   
   b. **Verify Security Groups**
   ```bash
   # RDS security group allows inbound on port 3306 from EC2
   # EC2 security group allows inbound on port 80
   ```
   
   c. **Test MySQL Connection from EC2**
   ```bash
   # SSH into EC2
   mysql -h datacenter-rds.xxxxxxxxxx.us-east-1.rds.amazonaws.com \
         -u datacenter_admin \
         -p datacenter_db
   # Enter password when prompted
   ```
   
   d. **Check Apache Logs**
   ```bash
   tail -f /var/log/httpd/error_log
   # Or
   tail -f /var/log/apache2/error.log
   ```
   
   e. **Verify PHP MySQL Extension**
   ```bash
   php -m | grep mysqli
   # If not present, install it
   yum install php-mysqlnd -y  # For Amazon Linux/RHEL
   apt install php-mysql -y     # For Ubuntu/Debian
   systemctl restart httpd
   ```

## Quick Command Reference
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/8576c0da212851ea1b93c87119af58643f8ada87/Day%2035%3A%20Deploying%20and%20Managing%20Applications%20on%20AWS/Screenshot%202026-01-15%20172500.png)
### AWS Client Host Commands
```bash
# Display credentials
showcreds

# Generate SSH key
ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa -N ""

# View public key
cat /root/.ssh/id_rsa.pub

# Copy file to EC2
scp -i /root/.ssh/id_rsa /root/index.php root@<EC2_IP>:/var/www/html/

# SSH to EC2
ssh -i /root/.ssh/id_rsa root@<EC2_IP>
```
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/8576c0da212851ea1b93c87119af58643f8ada87/Day%2035%3A%20Deploying%20and%20Managing%20Applications%20on%20AWS/Screenshot%202026-01-15%20172835.png)
### EC2 Instance Commands
```bash
# Test MySQL connection
mysql -h <RDS_ENDPOINT> -u datacenter_admin -p datacenter_db

# Check Apache status
systemctl status httpd

# Restart Apache
systemctl restart httpd

# View Apache error logs
tail -f /var/log/httpd/error_log
```
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/8576c0da212851ea1b93c87119af58643f8ada87/Day%2035%3A%20Deploying%20and%20Managing%20Applications%20on%20AWS/Screenshot%202026-01-15%20172823.png)
## Checklist

- [ ] RDS instance created with name `datacenter-rds`
- [ ] MySQL version 8.4.5 selected
- [ ] Instance type is db.t3.micro
- [ ] Master username is `datacenter_admin`
- [ ] Storage type is gp2 with 5 GiB
- [ ] Initial database `datacenter_db` created
- [ ] RDS status is "Available"
- [ ] RDS security group allows port 3306 from EC2
- [ ] EC2 security group allows port 80
- [ ] SSH key created on aws-client
- [ ] Public key added to EC2 instance
- [ ] SSH connection working without password
- [ ] index.php updated with correct RDS credentials
- [ ] index.php copied to /var/www/html/ on EC2
- [ ] Web browser shows "Connected successfully"

## Important Notes

1. **Region**: All resources must be created in **us-east-1**
2. **Session Time**: Credentials are valid for 1 hour only
3. **Private RDS**: The RDS instance is private and only accessible from within the VPC
4. **Security**: Never commit passwords to version control
5. **Cost**: db.t3.micro and 5GB gp2 storage are free tier eligible

## Completion Criteria

✅ RDS instance is in "Available" state  
✅ EC2 can connect to RDS on port 3306  
✅ Port 80 is open on EC2 instance  
✅ Password-less SSH working from aws-client to EC2  
✅ Browser displays "Connected successfully" message  

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/8576c0da212851ea1b93c87119af58643f8ada87/Day%2035%3A%20Deploying%20and%20Managing%20Applications%20on%20AWS/Screenshot%202026-01-15%20172057.png)
**Created for**: Nautilus DevOps Team  
**Date**: January 15, 2026  
**Region**: us-east-1
