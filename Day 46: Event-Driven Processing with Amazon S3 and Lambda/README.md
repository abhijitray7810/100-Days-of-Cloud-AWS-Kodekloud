# DevOps S3 File Automation with AWS Lambda and DynamoDB

## 📌 Project Overview

This project demonstrates an automated file management system using AWS services. The solution automatically copies files uploaded to a public S3 bucket into a private S3 bucket and logs all operations in a DynamoDB table.

The architecture improves **security, automation, and monitoring** for file transfers.

Whenever a user uploads a file to the public bucket, an AWS Lambda function is triggered. The Lambda function copies the file to a private bucket and records the event details in DynamoDB.

---

# 🏗 Architecture

```
User Upload
     │
     ▼
Public S3 Bucket
(devops-public-20913)
     │
     │  Trigger Event
     ▼
AWS Lambda Function
(devops-copyfunction)
     │
     ├── Copy file → Private S3 Bucket
     │        (devops-private-27007)
     │
     └── Log Operation → DynamoDB
              (devops-S3CopyLogs)
```

---

# ⚙️ AWS Services Used

* **Amazon S3**

  * Public bucket for file uploads
  * Private bucket for secure file storage

* **AWS Lambda**

  * Automatically triggered when a file is uploaded
  * Copies files from public bucket to private bucket

* **Amazon DynamoDB**

  * Stores logs for each file transfer

* **IAM (Identity and Access Management)**

  * Provides permissions for Lambda to access S3 and DynamoDB

* **CloudWatch**

  * Stores Lambda execution logs for monitoring and debugging

---

# 📂 Project Structure

```
project-folder
│
├── lambda-function.py
├── lambda-function.zip
└── README.md
```

---

# 🚀 Setup Instructions
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/fd2fbefcecd3ccde074b18d930552f33ea28ec80/Day%2046%3A%20Event-Driven%20Processing%20with%20Amazon%20S3%20and%20Lambda/Screenshot%202026-03-15%20190556.png)
## 1️⃣ Create Public S3 Bucket

Create an S3 bucket:

```
devops-public-20913
```

Settings:

* Region: `us-east-1`
* Disable **Block Public Access**
* Add bucket policy to allow public read access.

Example policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::devops-public-20913/*"
    }
  ]
}
```

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/60e2f19ed522f3dbf34872a61dcaa208c4ae7d55/Day%2046%3A%20Event-Driven%20Processing%20with%20Amazon%20S3%20and%20Lambda/Screenshot%202026-03-15%20190632.png)
# 2️⃣ Create Private S3 Bucket

Create another bucket:

```
devops-private-27007
```

Settings:

* Region: `us-east-1`
* Keep **Block Public Access Enabled**

This bucket will securely store files copied by the Lambda function.

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/ae960d7fb0910bfc4dd79cad1574fc3da0db90be/Day%2046%3A%20Event-Driven%20Processing%20with%20Amazon%20S3%20and%20Lambda/Screenshot%202026-03-15%20190647.png)
# 3️⃣ Create DynamoDB Table

Create a DynamoDB table:

```
Table Name: devops-S3CopyLogs
Partition Key: LogID (String)
```

This table will store logs containing:

* Source bucket name
* Destination bucket name
* Object key
* Timestamp
* Status of operation

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/13e88f9cbd08e8000e19791f022b34d68e98b0fc/Day%2046%3A%20Event-Driven%20Processing%20with%20Amazon%20S3%20and%20Lambda/Screenshot%202026-03-15%20190657.png)
# 4️⃣ Create IAM Role

Create an IAM Role for Lambda.

Role Name:

```
lambda_execution_role
```

Attach these policies:

* `AmazonS3FullAccess`
* `AmazonDynamoDBFullAccess`
* `AWSLambdaBasicExecutionRole`

This allows Lambda to:

* Read files from S3
* Write files to S3
* Store logs in DynamoDB
* Write logs to CloudWatch

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/3b5a6341ed8dd00d504f28ee09e4e7ccc63181a2/Day%2046%3A%20Event-Driven%20Processing%20with%20Amazon%20S3%20and%20Lambda/Screenshot%202026-03-15%20190714.png)
# 5️⃣ Create Lambda Function

Create a Lambda function.

```
Function Name: devops-copyfunction
Runtime: Python 3.9
Role: lambda_execution_role
```

Upload the Lambda code as a zip file.

Handler:

```
lambda-function.lambda_handler
```


![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/0ba3641c0d1dab8999ba04d52f838efc9e997482/Day%2046%3A%20Event-Driven%20Processing%20with%20Amazon%20S3%20and%20Lambda/Screenshot%202026-03-15%20190744.png)
# 6️⃣ Lambda Function Code

The Lambda function performs three main tasks:

1. Detect file upload event from S3
2. Copy file from public bucket to private bucket
3. Store log entry in DynamoDB

```python
import json
import boto3
from datetime import datetime
import uuid

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('devops-S3CopyLogs')

def lambda_handler(event, context):

    source_bucket = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']

    destination_bucket = "devops-private-27007"

    copy_source = {
        'Bucket': source_bucket,
        'Key': object_key
    }

    s3.copy_object(
        CopySource=copy_source,
        Bucket=destination_bucket,
        Key=object_key
    )

    log_entry = {
        'LogID': str(uuid.uuid4()),
        'SourceBucket': source_bucket,
        'DestinationBucket': destination_bucket,
        'ObjectKey': object_key,
        'Timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'Status': 'Success'
    }

    table.put_item(Item=log_entry)

    return {
        'statusCode': 200,
        'body': json.dumps('File copied successfully')
    }
```


![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/0a56dff5f9f531e4404259d9700c45d2b8954679/Day%2046%3A%20Event-Driven%20Processing%20with%20Amazon%20S3%20and%20Lambda/Screenshot%202026-03-15%20190800.png)
# 7️⃣ Configure S3 Trigger

Add an S3 trigger to the Lambda function.

Trigger configuration:

```
Bucket: devops-public-20913
Event Type: All Object Create Events
```

Now every file upload will trigger the Lambda function.

---
![image]()
# 🧪 Testing the Project

Upload a test file:

```
sample.zip
```

Command example:

```
aws s3 cp sample.zip s3://devops-public-20913
```

---
![image]()
# ✅ Verification

### 1️⃣ Check Private Bucket

Open:

```
devops-private-27007
```

Verify the file was copied successfully.

---

### 2️⃣ Check DynamoDB Logs

Open table:

```
devops-S3CopyLogs
```

You should see a record like:

```
LogID
SourceBucket
DestinationBucket
ObjectKey
Timestamp
Status
```

---

# 📊 Example Log Entry

```
LogID: 3b3e7e9b-2f3a-4a45-8c3c-8d8e1f63f6c7
SourceBucket: devops-public-20913
DestinationBucket: devops-private-27007
ObjectKey: sample.zip
Timestamp: 2026-03-15 12:30:22
Status: Success
```

---

# 🎯 Key Features

✔ Automated file transfer
✔ Serverless architecture
✔ Secure private file storage
✔ Real-time event-driven processing
✔ DynamoDB logging for audit tracking
✔ CloudWatch monitoring

---

# 📚 Learning Outcomes

From this project you will learn:

* Event-driven architecture
* AWS Lambda automation
* S3 event notifications
* DynamoDB logging
* IAM role and permissions
* Serverless DevOps workflows

---

# 👨‍💻 Author

**Abhijit Ray**

DevOps Engineer | Cloud Enthusiast

---

# ⭐ If you found this project helpful

Please consider giving the repository a **star ⭐ on GitHub**.
