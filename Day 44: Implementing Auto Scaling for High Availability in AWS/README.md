# AWS Auto Scaling + ALB with Nginx (xfusion)

This project sets up a **highly available web application** on AWS using:

* **EC2 Launch Template**
* **Auto Scaling Group (ASG)**
* **Application Load Balancer (ALB)**
* **Target Group**
* **CPU-based scaling**
* **Nginx web server**

All resources are created in **us-east-1**.

---

## Architecture

```
Internet
   |
Application Load Balancer (xfusion-alb)
   |
Target Group (xfusion-tg)
   |
Auto Scaling Group (xfusion-asg)
   |
EC2 Instances (Amazon Linux 2 + Nginx)
```

---

## Components

| Resource           | Name                    |
| ------------------ | ----------------------- |
| Launch Template    | xfusion-launch-template |
| Auto Scaling Group | xfusion-asg             |
| Target Group       | xfusion-tg              |
| Load Balancer      | xfusion-alb             |

---

## EC2 Configuration

* **AMI:** Amazon Linux 2
* **Instance Type:** t2.micro
* **Security Group:** Allows inbound HTTP (port 80)
* **User Data Script:**

```bash
#!/bin/bash
yum update -y
yum install -y nginx
systemctl start nginx
systemctl enable nginx
```

---

## Auto Scaling

* **Min:** 1 instance
* **Desired:** 1 instance
* **Max:** 2 instances
* **Scaling Policy:**

  * Target CPU utilization: **50%**

---

## Load Balancer

* **Type:** Application Load Balancer
* **Listener:** HTTP on port 80
* **Health Check:**

  * Protocol: HTTP
  * Path: `/`
  * Healthy only instances receive traffic.

---

## Verification

1. Open the **xfusion-alb DNS name** in a browser.
2. You should see the **default Nginx welcome page**.
3. Increase CPU load to confirm auto scaling works.

---

## Region

All resources are created in: **us-east-1**

---

## AWS Console Access

* **URL:** [https://046467849567.signin.aws.amazon.com/console?region=us-east-1](https://046467849567.signin.aws.amazon.com/console?region=us-east-1)
* **Username:** kk_labs_user_583035
* **Password:** h0Yn%M6DrQXe

---

## Cleanup

After testing, delete:

* ASG
* Launch Template
* Target Group
* ALB
* EC2 Security Groups

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/eb70e444c2206a7bff39b906a58657e46b2d7efc/Day%2044%3A%20Implementing%20Auto%20Scaling%20for%20High%20Availability%20in%20AWS/Screenshot%202026-01-31%20223018.png)

![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/eb70e444c2206a7bff39b906a58657e46b2d7efc/Day%2044%3A%20Implementing%20Auto%20Scaling%20for%20High%20Availability%20in%20AWS/Screenshot%202026-01-31%20224220.png)

![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/eb70e444c2206a7bff39b906a58657e46b2d7efc/Day%2044%3A%20Implementing%20Auto%20Scaling%20for%20High%20Availability%20in%20AWS/Screenshot%202026-01-31%20224240.png)

![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/eb70e444c2206a7bff39b906a58657e46b2d7efc/Day%2044%3A%20Implementing%20Auto%20Scaling%20for%20High%20Availability%20in%20AWS/Screenshot%202026-01-31%20224249.png)

![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/eb70e444c2206a7bff39b906a58657e46b2d7efc/Day%2044%3A%20Implementing%20Auto%20Scaling%20for%20High%20Availability%20in%20AWS/Screenshot%202026-01-31%20224300.png)

![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/eb70e444c2206a7bff39b906a58657e46b2d7efc/Day%2044%3A%20Implementing%20Auto%20Scaling%20for%20High%20Availability%20in%20AWS/Screenshot%202026-01-31%20224327.png)

![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/eb70e444c2206a7bff39b906a58657e46b2d7efc/Day%2044%3A%20Implementing%20Auto%20Scaling%20for%20High%20Availability%20in%20AWS/Screenshot%202026-01-31%20224422.png)

![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/eb70e444c2206a7bff39b906a58657e46b2d7efc/Day%2044%3A%20Implementing%20Auto%20Scaling%20for%20High%20Availability%20in%20AWS/Screenshot%202026-01-31%20224623.png)

![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/eb70e444c2206a7bff39b906a58657e46b2d7efc/Day%2044%3A%20Implementing%20Auto%20Scaling%20for%20High%20Availability%20in%20AWS/Screenshot%202026-01-31%20224623.png)

![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/eb70e444c2206a7bff39b906a58657e46b2d7efc/Day%2044%3A%20Implementing%20Auto%20Scaling%20for%20High%20Availability%20in%20AWS/Screenshot%202026-01-31%20224644.png)

![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/eb70e444c2206a7bff39b906a58657e46b2d7efc/Day%2044%3A%20Implementing%20Auto%20Scaling%20for%20High%20Availability%20in%20AWS/Screenshot%202026-01-31%20225307.png)

![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/eb70e444c2206a7bff39b906a58657e46b2d7efc/Day%2044%3A%20Implementing%20Auto%20Scaling%20for%20High%20Availability%20in%20AWS/Screenshot%202026-01-31%20225544.png)


✅ Setup complete!
