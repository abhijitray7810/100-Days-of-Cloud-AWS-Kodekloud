## **Task: Create `xfusion-sg` Security Group in Default VPC (us-east-1)**

This guide walks through creating a security group in AWS as part of the Nautilus DevOps team's incremental cloud migration strategy.

---

## **Prerequisites**

Use the provided temporary AWS console credentials:

* **Console URL:**
  `https://357140268957.signin.aws.amazon.com/console?region=us-east-1`
* **Username:** `kk_labs_user_915155`
* **Password:** `25W3tg7@Q2vy`
* **Valid From:** Mon Dec 08 16:52:38 UTC 2025
* **Valid Until:** Mon Dec 08 17:52:38 UTC 2025
* **Region:** `us-east-1`

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/acdc66766b7c1fad6c4fb39805b5cc738ef000d9/Day%202%3A%20Create%20Security%20Group/Screenshot%202025-12-08%20223029.png)

## **Steps to Create the Security Group**

### **1. Log in to AWS Console**

1. Open the console URL.
2. Enter the username and password.
3. Ensure the region is set to **N. Virginia (us-east-1)** in the top-right of the dashboard.

---

### **2. Navigate to EC2 Service**

1. In the AWS console search bar, type **EC2**.
2. Select **EC2 Dashboard**.

---

### **3. Open Security Groups**

1. In the left navigation panel, under **Network & Security**, click **Security Groups**.

---

### **4. Create a New Security Group**

1. Click **Create security group**.
2. Fill in the fields as follows:

   | Field                   | Value                                     |
   | ----------------------- | ----------------------------------------- |
   | **Security group name** | `xfusion-sg`                              |
   | **Description**         | `Security group for Nautilus App Servers` |
   | **VPC**                 | Select the **default VPC**                |

---

### **5. Add Inbound Rules**

#### **Rule 1 – HTTP**

* **Type:** HTTP
* **Port:** 80
* **Source:** `0.0.0.0/0`

#### **Rule 2 – SSH**

* **Type:** SSH
* **Port:** 22
* **Source:** `0.0.0.0/0`

Click **Add rule** to include both rules.

---

### **6. Create the Security Group**

1. Review the details.
2. Click **Create security group**.

---

### **7. Verification**

* You should now see `xfusion-sg` listed in the Security Groups panel.
* Check that:

  * It is associated with the **default VPC**.
  * It contains the **HTTP (80)** and **SSH (22)** inbound rules.

---

## **Completion**

You have successfully created the required security group (`xfusion-sg`) in the **us-east-1** region as part of the staged AWS migration plan.

---

If you want, I can also generate a **Terraform version**, a **CloudFormation template**, or **CLI commands** for this setup.
