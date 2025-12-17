The Nautilus DevOps team needs to set up a new EC2 instance that can be accessed securely from their landing host (aws-client). The instance should be of type t2.micro and named devops-ec2. A new SSH key should be created on the aws-client host under the/root/.ssh/ folder, if it doesn't already exist. This key should then be added to the root user's authorised keys on the EC2 instance, allowing passwordless SSH access from the aws-client host.


Use below given AWS Credentials: (You can run the showcreds command on aws-client host to retrieve these credentials)

Console URL	https://374085604821.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_948159
Password	Xq%87%@b%lRP
Start Time	Wed Dec 17 14:19:50 UTC 2025
End Time	Wed Dec 17 15:19:50 UTC 2025

Notes:

Create the resources only in us-east-1 region.

To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:
toggle button




