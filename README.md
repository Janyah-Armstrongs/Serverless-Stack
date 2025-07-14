# 🌍 Serverless API Stack

## 🛠 Built With

- **Terraform** – Infrastructure as Code
- **AWS Lambda** – Backend compute (Python 3.9)
- **API Gateway** – HTTP API for the Lambda function
- **DynamoDB** – NoSQL database for storing items

---

## 📁 Project Structure

```
Global-Serverless-Stack/
├── main.tf              # Main Terraform configuration
├── variables.tf         # Input variables
├── outputs.tf           # Useful Terraform outputs
├── lambda_function.py   # Python code for Lambda
├── lambda.zip           # Zipped Lambda function (for deployment)
├── zip_lambda.sh        # Helper script to zip Lambda
├── .gitignore           # Ignored files and folders
└── README.md            # This file
```

---

## 🚀 What It Does

This API allows users to send JSON data to an endpoint. The data is then stored in a DynamoDB table.

**Example POST body:**
```json
{
  "id": "1",
  "name": "Test Item"
}
```

### Flow:
**API Gateway → Lambda → DynamoDB → Response**

---

## 📦 How to Deploy

1. **Clone the Repo**
   ```bash
   git clone https://github.com/Janyah-Armstrongs/Serverless-Stack.git
   cd Serverless-Stack
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```
2.5 **Before Package Lambda**
  ```bash
    touch zip_lambda.sh
  ```
  ```bash
  nano zip_lambda.sh
  ```
  ```bash
  #!/bin/bash
  zip lambda.zip lambda_function.py
  ```
  ```bash
  chmod +x zip_lambda.sh
  ```

3. **Package Lambda**
   ```bash
   ./zip_lambda.sh
   ```

4. **Apply Infrastructure**
   ```bash
   terraform apply
   ```

---

## 🐞 Issues Faced & Fixes

- **Internal Server Error**: CloudWatch logs were not enabled → Fixed by attaching the correct IAM policy.
- **Large File Error**: `.terraform` directory pushed to GitHub → Fixed by adding `.gitignore` and deleting large binary files.
- **Lambda Access Denied**: Incorrect role or policy → Fixed by reviewing IAM permissions.
- **Missing Zip**: Lambda was not zipped correctly → Fixed by adding a zip script `zip_lambda.sh`.

---

## ✅ Best Practices Followed

- Minimal permissions (IAM least privilege)
- Consistent resource naming
- CloudWatch logging enabled
- `.gitignore` included to avoid pushing unnecessary files

