The Nautilus DevOps team is tasked with deploying a containerized application using Amazon's container services. They need to create a private Amazon Elastic Container Registry (ECR) to store their Docker images and use Amazon Elastic Container Service (ECS) to deploy the application. The process involves building a Docker image from a given Dockerfile, pushing it to the ECR, and then setting up an ECS cluster to run the application.

Create a Private ECR Repository:

Create a private ECR repository named devops-ecr to store Docker images.
Build and Push Docker Image:

Use the Dockerfile located at /root/pyapp on the aws-client host.
Build a Docker image using this Dockerfile.
Tag the image with latest tag.
Push the Docker image to the devops-ecr repository.
Create and Configure ECS cluster:

Create an ECS cluster named devops-cluster using the Fargate launch type.
Create an ECS Task Definition:

Define a task named devops-taskdefinition using the Docker image from the devops-ecr ECR repository.
Specify necessary CPU and memory resources.
Deploy the Application Using ECS Service:

Create a service named devops-service on the devops-cluster to run the task.
Ensure the service runs at least one task.

Use below given AWS Credentials: (You can run the showcreds command on aws-client host to retrieve these credentials)

Console URL	https://954973595150.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_324248
Password	S8CTtwr%i0dX
Start Time	Thu Jan 22 13:14:16 UTC 2026
End Time	Thu Jan 22 14:14:16 UTC 2026

Notes:

Create the resources only in us-east-1 region.

To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:
toggle button




