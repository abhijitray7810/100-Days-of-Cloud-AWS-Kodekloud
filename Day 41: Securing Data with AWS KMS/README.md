# 🔐 AWS KMS Encryption & Decryption Lab  
## DevOps 365 Days Challenge – Day 120

This project demonstrates hands-on implementation of **AWS Key Management Service (KMS)** to securely encrypt and decrypt sensitive data using the **AWS CLI**.

The goal of this lab was to create a **customer-managed symmetric KMS key**, encrypt a sensitive file, safely store the encrypted data, and verify successful decryption — exactly as done in real-world DevOps and cloud security workflows.

---

## 📌 Problem Statement

The Nautilus DevOps team wants to improve data security using AWS KMS.

### Requirements:
- Create a **symmetric KMS key** named `datacenter-KMS-Key`
- Encrypt a sensitive file using AWS KMS
- Base64 encode the encrypted ciphertext
- Store the encrypted output as `EncryptedData.bin`
- Decrypt the encrypted file and verify data integrity
- Ensure the setup passes an automated validation script

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/da7e0d643aba75da19f4499fd67309a258e8638a/Day%2041%3A%20Securing%20Data%20with%20AWS%20KMS/Screenshot%202026-01-26%20111709.png)
## 🛠️ Tools & Services Used

- **AWS KMS**
- **AWS CLI**
- **Linux (CLI)**
- **Base64 Encoding/Decoding**

---

## 🌍 AWS Configuration

- **Region:** `us-east-1`
- **KMS Key Type:** Customer-managed
- **Key Spec:** `SYMMETRIC_DEFAULT`
- **Key Usage:** Encrypt & Decrypt
- **Alias:** `alias/datacenter-KMS-Key`

---

## 📂 Project Structure

```

.
├── SensitiveData.txt        # Original sensitive file
├── EncryptedData.bin        # Encrypted binary output (KMS ciphertext)
├── DecryptedData.txt        # Decrypted output for verification
└── README.md

````

---

## 🚀 Implementation Steps
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/da7e0d643aba75da19f4499fd67309a258e8638a/Day%2041%3A%20Securing%20Data%20with%20AWS%20KMS/Screenshot%202026-01-26%20114215.png)
### 1️⃣ Create a Symmetric KMS Key
```bash
aws kms create-key \
  --description "datacenter-KMS-Key" \
  --key-usage ENCRYPT_DECRYPT \
  --origin AWS_KMS
````

### 2️⃣ Create an Alias for the Key

```bash
aws kms create-alias \
  --alias-name alias/datacenter-KMS-Key \
  --target-key-id <KEY_ID>
```

---

### 3️⃣ Encrypt the Sensitive File

Encrypt `SensitiveData.txt`, extract only the ciphertext, decode it, and store it as a binary file:

```bash
aws kms encrypt \
  --key-id alias/datacenter-KMS-Key \
  --plaintext fileb://SensitiveData.txt \
  --query CiphertextBlob \
  --output text | base64 --decode > EncryptedData.bin
```

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/da7e0d643aba75da19f4499fd67309a258e8638a/Day%2041%3A%20Securing%20Data%20with%20AWS%20KMS/Screenshot%202026-01-26%20112156.png)
### 4️⃣ Decrypt the Encrypted File

```bash
aws kms decrypt \
  --ciphertext-blob fileb://EncryptedData.bin \
  --query Plaintext \
  --output text | base64 --decode > DecryptedData.txt
```

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/da7e0d643aba75da19f4499fd67309a258e8638a/Day%2041%3A%20Securing%20Data%20with%20AWS%20KMS/Screenshot%202026-01-26%20112525.png)
### 5️⃣ Verify Data Integrity

```bash
diff SensitiveData.txt DecryptedData.txt
```

✔ No output confirms that the decrypted file matches the original.

---

## ❌ Issues Faced & Fixes
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/da7e0d643aba75da19f4499fd67309a258e8638a/Day%2041%3A%20Securing%20Data%20with%20AWS%20KMS/Screenshot%202026-01-26%20114134.png)
### Issue:

* Incorrect encrypted file name (`ExampleEncryptedFile`)
* Validation failed because it expected **EncryptedData.bin**

### Fix:

* Followed correct encryption → base64 decode → `.bin` workflow
* Used **KMS alias** instead of raw KeyId
* Ensured exact filename expected by the validation script

---

## 💡 Key Learnings

* AWS KMS returns ciphertext in **base64 format**
* Filenames matter in automated validation
* Using **KMS aliases** prevents KeyId confusion
* CLI-based encryption is critical for automation and DevSecOps

---

## ✅ Final Outcome

* ✔ Secure encryption using AWS KMS
* ✔ Successful decryption and verification
* ✔ Passed validation requirements
* ✔ Hands-on experience with cloud security

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/da7e0d643aba75da19f4499fd67309a258e8638a/Day%2041%3A%20Securing%20Data%20with%20AWS%20KMS/Screenshot%202026-01-26%20114144.png)
## 📅 Challenge Progress

**DevOps 365 Days Challenge – Day 120**

> Learning in public. Building real skills. One day at a time 🚀

---

## 🔗 Connect With Me

* **LinkedIn:** *(add your LinkedIn link)*
* **GitHub:** *(this repository)*

---

## 🏷️ Tags

`AWS` `KMS` `DevOps` `CloudSecurity` `AWSCLI` `LearningInPublic`

```

---

If you want, next I can:
- Optimize this README for **recruiter scanning**
- Add **badges + architecture diagram**
- Help you maintain a **DevOps 365 master README**
- Turn this into a **portfolio project description**

You’re doing exactly what strong DevOps candidates do — keep going 💪🚀
```

![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/da7e0d643aba75da19f4499fd67309a258e8638a/Day%2041%3A%20Securing%20Data%20with%20AWS%20KMS/Screenshot%202026-01-26%20114215.png)
![image]()
