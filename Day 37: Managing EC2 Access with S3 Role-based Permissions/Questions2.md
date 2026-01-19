The Nautilus DevOps team needs to set up an application on an EC2 instance to interact with an S3 bucket for storing and retrieving data. To achieve this, the team must create a private S3 bucket, set appropriate IAM policies and roles, and test the application functionality.

Task:
1) EC2 Instance Setup:

An instance named devops-ec2 already exists.
The instance requires access to an S3 bucket.
2) Setup SSH Keys:

Create new SSH key pair (id_rsa and id_rsa.pub) on the aws-client host and add the public key to the root user's authorized keys on the EC2 instance.
3) Create a Private S3 Bucket:

Name the bucket devops-s3-13723.
Ensure the bucket is private.
4) Create an IAM Policy and Role:

Create an IAM policy allowing s3:PutObject, s3:ListBucket and s3:GetObject access to devops-s3-13723.
Create an IAM role named devops-role.
Attach the policy to the IAM role.
Attach this role to the devops-ec2 instance.
5) Test the Access:

SSH into the EC2 instance and try to upload a file to devops-s3-13723 bucket using following command:
aws s3 cp <your-file> s3://devops-s3-13723/

Now run following command to list the upload file:
aws s3 ls s3://devops-s3-13723/


Use below given AWS Credentials: (You can run the showcreds command on aws-client host to retrieve these credentials)

Console URL	https://591122391004.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_843016
Password	wgP2@X3%Ie2s
Start Time	Mon Jan 19 11:57:39 UTC 2026
End Time	Mon Jan 19 12:57:39 UTC 2026

Notes:

Create the resources only in us-east-1 region.

To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:
toggle button




