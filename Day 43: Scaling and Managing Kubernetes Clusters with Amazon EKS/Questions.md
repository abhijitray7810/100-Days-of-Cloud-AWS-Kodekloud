The Nautilus DevOps team has been tasked with preparing the infrastructure for a new Kubernetes-based application that will be deployed using Amazon EKS. The team is in the process of setting up an EKS cluster that meets their internal security and scalability standards. They require that the cluster be provisioned using the latest stable Kubernetes version to take advantage of new features and security improvements.

To minimize external exposure, the EKS cluster endpoint must be kept private. Additionally, the cluster needs to use the default VPC with availability zones a, b, and c to ensure high availability across different physical locations.

Your task is to create an EKS cluster named xfusion-eks, along with an IAM role for the cluster named eksClusterRole. The Kubernetes version must be 1.30. Ensure that the cluster endpoint access is configured as private.

Finally, verify that the EKS cluster is successfully created with the correct configuration and is ready for workloads.


Use below given AWS Credentials: (You can run the showcreds command on aws-client host to retrieve these credentials)

Console URL	https://143588534152.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_568020
Password	nDVI@1p!%8^m
Start Time	Thu Jan 29 05:00:49 UTC 2026
End Time	Thu Jan 29 06:00:49 UTC 2026

Notes:

Create the resources only in us-east-1 region.

To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:
toggle button
