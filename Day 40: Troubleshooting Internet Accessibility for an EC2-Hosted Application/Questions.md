The Nautilus Development Team recently deployed a new web application hosted on an EC2 instance within a public VPC named nautilus-vpc. The application, running on an Nginx server, should be accessible from the internet on port 80. Despite configuring the security group nautilus-sg to allow traffic on port 80 and verifying the EC2 instance settings, the application remains inaccessible from the internet. The team suspects that the issue might be related to the VPC configuration, as all other components appear to be set up correctly. The DevOps team has been asked to troubleshoot and resolve the issue to ensure the application is accessible to external users.

As a member of the Nautilus DevOps Team, your task is to perform the following:

Verify VPC Configuration: Ensure that the VPC nautilus-vpc is properly configured to allow internet access.

Ensure Accessibility: Make sure the EC2 instance nautilus-ec2 running the Nginx server is accessible from the internet on port 80.



Use below given AWS Credentials: (You can run the showcreds command on aws-client host to retrieve these credentials)

Console URL	https://678838728594.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_502460
Password	N%@Hiyh7Daz4
Start Time	Sat Jan 24 12:17:19 UTC 2026
End Time	Sat Jan 24 13:17:19 UTC 2026

Notes:

Create the resources only in us-east-1 region.
To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:\ntoggle button



