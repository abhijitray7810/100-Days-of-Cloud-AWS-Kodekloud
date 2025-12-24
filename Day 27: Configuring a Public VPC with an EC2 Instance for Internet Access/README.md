## Public VPC, Subnet, and EC2 Setup (datacenter-pub)
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/f83709bdfd9b76d15137b5af089701e2e2230a14/Day%2027%3A%20Configuring%20a%20Public%20VPC%20with%20an%20EC2%20Instance%20for%20Internet%20Access/Screenshot%202025-12-24%20181412.png)
### Objective

Create a public VPC with a public subnet that automatically assigns public IPs, and launch an EC2 instance that is accessible over the internet via SSH (port 22).

All resources must be created in **AWS Region: us-east-1**.

---
![image]()
## Prerequisites

* AWS Console access using the provided credentials
* Region set to **N. Virginia (us-east-1)**

> ⚠️ Ensure you are working **only in us-east-1**

---

## Step 1: Login to AWS Console

1. Open the AWS Console URL:

   ```
   https://831788756997.signin.aws.amazon.com/console?region=us-east-1
   ```
2. Login using the provided **username** and **password**
3. Confirm the region (top-right corner) is **us-east-1**

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/4408783483fff30526a9d3b56c723018224f3c89/Day%2027%3A%20Configuring%20a%20Public%20VPC%20with%20an%20EC2%20Instance%20for%20Internet%20Access/Screenshot%202025-12-24%20181251.png)
## Step 2: Create a Public VPC

1. Go to **VPC Dashboard**
2. Click **Your VPCs**
3. Click **Create VPC**
4. Choose **VPC only**
5. Configure:

   * **Name tag:** `datacenter-pub-vpc`
   * **IPv4 CIDR block:** `10.0.0.0/16`
   * **Tenancy:** Default
6. Click **Create VPC**

---

## Step 3: Create an Internet Gateway

1. In **VPC Dashboard**, click **Internet Gateways**
2. Click **Create internet gateway**
3. Set:

   * **Name tag:** `datacenter-pub-igw`
4. Click **Create internet gateway**
5. Select the newly created IGW
6. Click **Actions → Attach to VPC**
7. Select `datacenter-pub-vpc`
8. Click **Attach internet gateway**

---

## Step 4: Create a Public Subnet

1. Go to **Subnets**
2. Click **Create subnet**
3. Configure:

   * **VPC:** `datacenter-pub-vpc`
   * **Subnet name:** `datacenter-pub-subnet`
   * **Availability Zone:** us-east-1a
   * **IPv4 CIDR block:** `10.0.1.0/24`
4. Click **Create subnet**

---

## Step 5: Enable Auto-Assign Public IPs on Subnet

1. Select `datacenter-pub-subnet`
2. Click **Actions → Edit subnet settings**
3. Enable:

   * ✅ **Auto-assign public IPv4 address**
4. Click **Save**

---

## Step 6: Create a Public Route Table

1. Go to **Route Tables**
2. Click **Create route table**
3. Configure:

   * **Name:** `datacenter-pub-rt`
   * **VPC:** `datacenter-pub-vpc`
4. Click **Create route table**

### Add Internet Route

1. Select `datacenter-pub-rt`
2. Go to **Routes tab**
3. Click **Edit routes**
4. Click **Add route**

   * **Destination:** `0.0.0.0/0`
   * **Target:** Internet Gateway → `datacenter-pub-igw`
5. Click **Save routes**

### Associate Subnet

1. Go to **Subnet associations**
2. Click **Edit subnet associations**
3. Select `datacenter-pub-subnet`
4. Click **Save associations**

---

## Step 7: Create Security Group for SSH Access

1. Go to **EC2 Dashboard → Security Groups**
2. Click **Create security group**
3. Configure:

   * **Name:** `datacenter-pub-sg`
   * **Description:** Allow SSH access from internet
   * **VPC:** `datacenter-pub-vpc`

### Inbound Rule

* Type: **SSH**
* Protocol: TCP
* Port: **22**
* Source: **0.0.0.0/0**

4. Click **Create security group**

---

## Step 8: Launch EC2 Instance

1. Go to **EC2 Dashboard → Instances**
2. Click **Launch instance**

### Instance Configuration

* **Name:** `datacenter-pub-ec2`
* **AMI:** Amazon Linux 2 (default)
* **Instance type:** `t2.micro`

### Key Pair

* Create or select an existing key pair
* Download and store it securely (required for SSH)

### Network Settings

* **VPC:** `datacenter-pub-vpc`
* **Subnet:** `datacenter-pub-subnet`
* **Auto-assign public IP:** Enabled
* **Security group:** `datacenter-pub-sg`

3. Click **Launch instance**

---

## Step 9: Verify Setup

1. Select the EC2 instance `datacenter-pub-ec2`
2. Confirm:

   * Public IPv4 address is assigned
   * Security group allows SSH (port 22)
3. Use the public IP to SSH:

   ```bash
   ssh -i <key.pem> ec2-user@<public-ip>
   ```

---

## Final Outcome

✅ Public VPC created
✅ Public subnet with auto-assigned public IPs
✅ Internet Gateway and routing configured
✅ EC2 instance (`t2.micro`) publicly accessible
✅ SSH (port 22) open to the internet

---

**Task Completed Successfully 🚀**
