The Nautilus Development Team needs to set up a new EC2 instance and configure it to run a web server. This EC2 instance should be part of an Application Load Balancer (ALB) setup to ensure high availability and better traffic management. The task involves creating an EC2 instance, setting up an ALB, configuring a target group, and ensuring the web server is accessible via the ALB DNS.

Create a security group: Create a security group named devops-sg to open port 80 for the default security group (which will be attached to the ALB). Attach devops-sg security group to the EC2 instance.

Create an EC2 instance: Create an EC2 instance named devops-ec2. Use any available Ubuntu AMI to create this instance. Configure the instance to run a user data script during its launch.

This script should:

Install the Nginx package.
Start the Nginx service.
Set up an Application Load Balancer: Set up an Application Load Balancer named devops-alb. Attach default security group to the same.

Create a target group: Create a target group named devops-tg.

Route traffic: The ALB should route traffic on port 80 to port 80 of the devops-ec2 instance.

Security group adjustments: Make appropriate changes in the default security group attached to the ALB if necessary. Eventually, the Nginx server running under devops-ec2 instance must be accessible using the ALB DNS.


Use below given AWS Credentials: (You can run the showcreds command on aws-client host to retrieve these credentials)

Console URL	https://341635973749.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_710522
Password	w^D%@J8^eMVH
Start Time	Sun Jan 18 13:36:05 UTC 2026
End Time	Sun Jan 18 14:36:05 UTC 2026

Notes:

Create the resources only in us-east-1 region.

To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:
toggle button




