## Day 119: AWS S3 Static Website Hosting
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/39a5094c9606c4e35b290f3bc8ffcac68b1896c8/Day%2039%3A%20Hosting%20a%20Static%20Website%20on%20AWS%20S3/Screenshot%202026-01-23%20193027.png)
### 📅 Date: January 23, 2026

---

## 🎯 Project Overview

Today's challenge involved setting up a static website hosting solution on AWS S3 for the Nautilus DevOps team. The goal was to create an internal information portal accessible to the public via an S3 bucket configured for static website hosting.

---

## 🏗️ Architecture

```
Internet Users
     |
     v
AWS S3 Bucket (datacenter-web-15817)
     |
     +-- Static Website Hosting Enabled
     +-- Public Access Configured
     +-- Bucket Policy Applied
     +-- index.html (Uploaded)
```

---

## 📋 Task Requirements

1. ✅ Create an S3 bucket named `datacenter-web-15817`
2. ✅ Configure the S3 bucket for static website hosting with `index.html` as the index document
3. ✅ Allow public access to the bucket
4. ✅ Upload the `index.html` file from the `/root/` directory to the S3 bucket
5. ✅ Verify website accessibility through the S3 website URL

---

## 🛠️ Implementation Steps
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/8dcf13a82581875b6ae95a9c11a27de18a56dbd1/Day%2039%3A%20Hosting%20a%20Static%20Website%20on%20AWS%20S3/Screenshot%202026-01-23%20193156.png)
### Step 1: Create S3 Bucket
```bash
aws s3 mb s3://datacenter-web-15817 --region us-east-1
```

### Step 2: Upload index.html
```bash
aws s3 cp /root/index.html s3://datacenter-web-15817/
```

### Step 3: Configure Static Website Hosting
```bash
aws s3 website s3://datacenter-web-15817/ \
  --index-document index.html \
  --error-document error.html
```

### Step 4: Configure Public Access
- Disabled "Block all public access" settings
- Applied bucket policy for public read access

### Step 5: Apply Bucket Policy
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::datacenter-web-15817/*"
    }
  ]
}
```

---

## 🔧 Technologies Used

- **Cloud Platform**: Amazon Web Services (AWS)
- **Service**: Amazon S3 (Simple Storage Service)
- **Region**: us-east-1 (N. Virginia)
- **Tools**: AWS CLI, AWS Management Console

---

## 📊 Project Outcomes
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/6a8b890ef025fbdd45462b67cdec0e5d5f82dcb1/Day%2039%3A%20Hosting%20a%20Static%20Website%20on%20AWS%20S3/Screenshot%202026-01-23%20193228.png)
### ✅ Successfully Achieved:
- Created S3 bucket with proper naming convention
- Enabled static website hosting configuration
- Configured public access permissions
- Applied appropriate bucket policy
- Uploaded website content
- Verified public accessibility

### 🌐 Website URL:
```
http://datacenter-web-15817.s3-website-us-east-1.amazonaws.com
```

---

## 🎓 Key Learnings

1. **S3 Static Hosting**: Understanding how S3 can serve as a cost-effective hosting solution for static websites
2. **IAM & Permissions**: Configuring proper bucket policies and public access settings
3. **AWS CLI**: Using command-line tools for efficient resource management
4. **Security Best Practices**: Balancing public accessibility with security considerations
5. **Resource Naming**: Following naming conventions for cloud resources

---

## 🔐 Security Considerations

- **Public Access**: Bucket is configured for public read access (as required)
- **Bucket Policy**: Applied minimal permissions (GetObject only)
- **Best Practice**: In production, consider using CloudFront for HTTPS and better performance
- **Monitoring**: Enable S3 access logging for audit trails

---

## 📝 Challenges Faced
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/2f37731a921515543d520b1380ea5a89c190e19b/Day%2039%3A%20Hosting%20a%20Static%20Website%20on%20AWS%20S3/Screenshot%202026-01-23%20194409.png)
### Initial Challenge:
- Received "403 Forbidden" error when accessing the S3 website URL
- **Root Cause**: Block public access settings were still enabled

### Resolution:
1. Navigated to Bucket Permissions
2. Disabled all "Block public access" settings
3. Applied the bucket policy for public read access
4. Verified access - website became accessible

---

## 🚀 Future Enhancements

- [ ] Add CloudFront distribution for CDN capabilities
- [ ] Implement custom domain with Route 53
- [ ] Add SSL/TLS certificate for HTTPS
- [ ] Set up S3 versioning for content management
- [ ] Configure CloudWatch alarms for monitoring
- [ ] Implement CI/CD pipeline for automated deployments

---

## 📸 Screenshots

### Terminal Commands
![Terminal showing AWS CLI commands](terminal-screenshot.png)

### S3 Bucket Configuration
![S3 bucket settings in AWS Console](s3-bucket-config.png)

### Bucket Policy
![Applied bucket policy for public access](bucket-policy.png)

### Website Accessibility
![Live website showing 403 error before fix](website-403-error.png)

### Block Public Access Settings
![Disabled block public access settings](block-public-access.png)

### Final Success
![S3 bucket listing in AWS Console](s3-buckets-list.png)

---

## 💡 Best Practices Applied

1. **Resource Naming**: Used descriptive, standardized naming convention
2. **Region Selection**: Deployed in us-east-1 as specified
3. **Documentation**: Maintained detailed documentation throughout
4. **Verification**: Tested functionality before completion
5. **Troubleshooting**: Systematically resolved access issues

---

## 📚 Resources & References

- [AWS S3 Static Website Hosting Documentation](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [AWS S3 Bucket Policies](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-policies.html)
- [AWS CLI S3 Commands](https://docs.aws.amazon.com/cli/latest/reference/s3/)

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/06c4ce01906924f7a793a12aa283eb670a6b7ed2/Day%2039%3A%20Hosting%20a%20Static%20Website%20on%20AWS%20S3/Screenshot%202026-01-23%20194439.png)
## 🤝 Connect With Me

I'm documenting my DevOps journey as part of the **#DevOps365Days** challenge!

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://www.linkedin.com/in/yourprofile)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black)](https://github.com/yourprofile)
[![Twitter](https://img.shields.io/badge/Twitter-Follow-1DA1F2)](https://twitter.com/yourprofile)

---

## 🏷️ Tags

`#DevOps` `#AWS` `#S3` `#CloudComputing` `#DevOps365Days` `#Day119` `#StaticWebsite` `#CloudStorage` `#LearningInPublic` `#TechJourney`

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/2677239546bffccc309e5d739d67af91d005e689/Day%2039%3A%20Hosting%20a%20Static%20Website%20on%20AWS%20S3/Screenshot%202026-01-23%20194429.png)
## 📌 Progress Tracker

- **Day**: 119/365
- **Category**: Cloud Computing - AWS S3
- **Difficulty**: Intermediate
- **Time Spent**: 1 hour
- **Status**: ✅ Completed

---

## 💬 Reflection

Today's project reinforced the importance of understanding AWS permissions and public access configurations. The initial 403 error taught me valuable troubleshooting skills and the need to carefully review security settings when deploying publicly accessible resources.

Static website hosting on S3 is an excellent, cost-effective solution for hosting simple websites, landing pages, or documentation portals. The integration with other AWS services like CloudFront and Route 53 makes it a powerful platform for scalable web hosting.

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/8e8ed915682ec98d8a0eb664b42325f7db7e2286/Day%2039%3A%20Hosting%20a%20Static%20Website%20on%20AWS%20S3/Screenshot%202026-01-23%20194505.png)
## 🎉 Next Steps

Tomorrow (Day 120), I'll be exploring **[Next Topic]** to continue building my DevOps expertise!

---

**#KeepLearning #DevOpsCommunity #CloudNative #AWSCertified**

---

*Last Updated: January 23, 2026*
