# AWS Lambda Function – xfusion-lambda-cli

This project demonstrates the creation and deployment of an AWS Lambda function using the AWS CLI. The Lambda function returns a custom greeting message and is intended to help the Nautilus DevOps team explore serverless architecture.

---

## 📌 Objective

- Create a Python-based AWS Lambda function
- Package the function code as a ZIP file
- Deploy and manage the Lambda function using AWS CLI
- Validate the function output

---

## 🛠️ Prerequisites

- AWS CLI installed and configured
- IAM role with Lambda execution permissions
  - Role name: `lambda_execution_role`
- Python 3.x
- Access to an AWS account

---

## 📂 Project Structure

```text
.
├── lambda_function.py
├── function.zip
└── README.md
````

---

## 🧾 Lambda Function Code

**File:** `lambda_function.py`

```python
def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": "Welcome to KKE AWS Labs!"
    }
```

---

## 📦 Create Deployment Package

```bash
zip function.zip lambda_function.py
```

---

## 🚀 Create Lambda Function

```bash
aws lambda create-function \
  --function-name xfusion-lambda-cli \
  --runtime python3.9 \
  --role arn:aws:iam::<ACCOUNT_ID>:role/lambda_execution_role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip
```

> Replace `<ACCOUNT_ID>` with your actual AWS account ID.

---

## 🔁 Update Existing Lambda Code

If the function already exists:

```bash
aws lambda update-function-code \
  --function-name xfusion-lambda-cli \
  --zip-file fileb://function.zip
```

---

## 🧪 Test the Lambda Function

```bash
aws lambda invoke \
  --function-name xfusion-lambda-cli \
  response.json
```

```bash
cat response.json
```

### Expected Output

```json
{
  "statusCode": 200,
  "body": "Welcome to KKE AWS Labs!"
}
```

---

## 📊 Verification

```bash
aws lambda get-function --function-name xfusion-lambda-cli
```

---

## ✅ Result

* Lambda function deployed successfully
* Function returns HTTP 200 with a custom greeting message
* Serverless deployment completed using AWS CLI

---

## 🧠 Key Learnings

* AWS Lambda deployment using CLI
* Packaging Python functions for Lambda
* IAM role usage with Lambda
* Updating Lambda function code

---

## 📎 Author

**Abhijit Ray**
DevOps | Cloud | AWS | Kubernetes

---

```

---

If you want, I can also:
- Optimize this for **GitHub portfolio**
- Write a **LinkedIn DevOps Day post**
- Add **badges and screenshots section**

Just tell me 👍
```
