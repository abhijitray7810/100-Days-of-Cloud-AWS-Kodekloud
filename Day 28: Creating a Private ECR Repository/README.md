## Private Amazon ECR Setup and Docker Image Push
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/d51e902b55ce2c1276bc7f540b93abaca93543cc/Day%2028%3A%20Creating%20a%20Private%20ECR%20Repository/Screenshot%202025-12-24%20183758.png)
### Objective

Set up a **private Amazon Elastic Container Registry (ECR)** repository, build a Docker image from an existing Dockerfile, and push the image to ECR with the `latest` tag.

All resources are created in **AWS Region: us-east-1**.

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/c38dd11d5d9bfd268e77c19e32614c5c1468fe17/Day%2028%3A%20Creating%20a%20Private%20ECR%20Repository/Screenshot%202025-12-24%20183811.png)
## Prerequisites

* Access to **aws-client host**
* AWS CLI configured with provided credentials
* Docker installed and running
* Dockerfile available at `/root/pyapp`

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/3296cc9d83d926fbb667b27bcbbdeabaaba8bde4/Day%2028%3A%20Creating%20a%20Private%20ECR%20Repository/Screenshot%202025-12-24%20183843.png)
## Step 1: Verify AWS Credentials

On the **aws-client host**, retrieve and verify credentials:

```bash
showcreds
```

Ensure:

* Account ID: `377820138963`
* Region: `us-east-1`

---
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/876a046e7e30da05f6dbe082f8f457952ae952ea/Day%2028%3A%20Creating%20a%20Private%20ECR%20Repository/Screenshot%202025-12-24%20183901.png)
## Step 2: Create a Private ECR Repository

Run the following command to create a private ECR repository named `devops-ecr`:

```bash
aws ecr create-repository \
  --repository-name devops-ecr \
  --region us-east-1
```

✅ Repository successfully created.

---

## Step 3: Navigate to Application Directory

Change to the directory containing the Dockerfile:

```bash
cd /root/pyapp
```

Verify Dockerfile exists:

```bash
ls
```

---

## Step 4: Build Docker Image

Build the Docker image using the Dockerfile and tag it as `latest`:

```bash
docker build -t pyapp .
```

Confirm image creation:

```bash
docker images
```

---

## Step 5: Tag Docker Image for ECR

Tag the locally built image with the ECR repository URI:

```bash
docker tag pyapp:latest \
377820138963.dkr.ecr.us-east-1.amazonaws.com/devops-ecr:latest
```

Verify tagging:

```bash
docker images
```

---

## Step 6: Authenticate Docker to ECR

Authenticate Docker to the Amazon ECR registry:

```bash
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin \
377820138963.dkr.ecr.us-east-1.amazonaws.com
```

✅ Login succeeded.

---

## Step 7: Push Image to ECR

Push the Docker image to the ECR repository:

```bash
docker push \
377820138963.dkr.ecr.us-east-1.amazonaws.com/devops-ecr:latest
```

Confirm successful upload:

* All image layers pushed
* `latest` tag available in ECR

---

## Step 8: Verify in AWS Console

1. Open AWS Console → **ECR**
2. Select **devops-ecr**
3. Confirm:

   * Image tag: `latest`
   * Image digest present

---

## Final Outcome

✅ Private ECR repository created
✅ Docker image built from Dockerfile
✅ Image tagged as `latest`
✅ Image successfully pushed to Amazon ECR

---

**Task completed successfully 🚀**
