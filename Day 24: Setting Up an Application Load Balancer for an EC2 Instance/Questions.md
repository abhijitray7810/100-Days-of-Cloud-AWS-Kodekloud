The Nautilus DevOps team is currently working on setting up a simple application on the AWS cloud. They aim to establish an Application Load Balancer (ALB) in front of an EC2 instance where an Nginx server is currently running. While the Nginx server currently serves a sample page, the team plans to deploy the actual application later.

Set up an Application Load Balancer named xfusion-alb.
Create a target group named xfusion-tg.
Create a security group named xfusion-sg to open port 80 for the public.
Attach this security group to the ALB.
The ALB should route traffic on port 80 to port 80 of the xfusion-ec2 instance.
Make appropriate changes in the default security group attached to the EC2 instance if necessary.


Use below given AWS Credentials: (You can run the showcreds command on aws-client host to retrieve these credentials)

Console URL	https://313579877827.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_723719
Password	v!d!nz8r@eBN
Start Time	Fri Dec 19 13:46:35 UTC 2025
End Time	Fri Dec 19 14:46:35 UTC 2025

Notes:

Create the resources only in us-east-1 region.

To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:
toggle button
