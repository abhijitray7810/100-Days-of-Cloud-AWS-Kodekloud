## Steps to Create the Subnet

### 1. Log in to the AWS Console

* Open the console URL provided.
* Enter the username and password.
* Ensure the region in the top-right corner is **us-east-1**.

### 2. Navigate to the VPC Dashboard

1. In the AWS Console, go to **Services**.
2. Search for **VPC** and open it.

### 3. Identify the Default VPC

* In the left sidebar, click **Your VPCs**.
* Locate the VPC with the **Default VPC** attribute set to **Yes**.
* Copy the **VPC ID** for this default VPC.
* [image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/4f237bbb6cb49d019107ef4bcb187c331cb0b05b/Day%203%3A%20Create%20Subnet/Screenshot%202025-12-08%20224525.png)

### 4. Create the Subnet

1. In the left sidebar, click **Subnets**.
2. Click **Create subnet**.
3. Fill in the details:

   * **Name tag:** `nautilus-subnet`
   * **VPC ID:** Select the **default VPC** you identified.
   * **Availability Zone:** Select any AZ within **us-east-1**.
   * **IPv4 CIDR block:** Provide a valid unused CIDR block (example: `172.31.48.0/20` if available).
4. Click **Create subnet**.

---

## Verification

After creation:

1. Ensure the subnet appears in the **Subnets** list.
2. Confirm that:

   * The name is correct: `nautilus-subnet`
   * It belongs to the **default VPC**
   * The region is **us-east-1**

---

## Notes

* Do **not** modify or delete existing subnets or VPC resources unless explicitly required.
* Only the creation of this single subnet is needed for the task.

---

If you need a CLI version of these instructions or Terraform templates, feel free to ask!
