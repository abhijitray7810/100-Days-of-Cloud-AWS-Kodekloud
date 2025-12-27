The Nautilus DevOps team is tasked with enabling internet access for an EC2 instance running in a private subnet. This instance should be able to upload a test file to a public S3 bucket once it can access the internet. To minimize costs, the team has decided to use a NAT Instance instead of a NAT Gateway.

The following components already exist in the environment:
1) A VPC named datacenter-priv-vpc and a private subnet named datacenter-priv-subnet have been created.
2) An EC2 instance named datacenter-priv-ec2 is already running in the private subnet.
3) The EC2 instance is configured with a cron job that uploads a test file to the S3 bucket datacenter-nat-23788 every minute. Upload will only succeed once internet access is established.

Your task is to:

Create a new public subnet named datacenter-pub-subnet in the existing VPC.
Launch a NAT Instance in the public subnet using an Amazon Linux 2 AMI and name it datacenter-nat-instance. Configure this instance to act as a NAT instance. Make sure to use a custom security group for this instance.
After the configuration, verify that the test file datacenter-test.txt appears in the S3 bucket datacenter-nat-23788. This indicates successful internet access from the private EC2 instance via the NAT Instance.


Use below given AWS Credentials: (You can run the showcreds command on aws-client host to retrieve these credentials)

Console URL	https://059254148810.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_831262
Password	cFZ^%G0!9kS9
Start Time	Sat Dec 27 14:18:36 UTC 2025
End Time	Sat Dec 27 14:18:36 UTC 2025

Notes:

Use region us-east-1

To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:
toggle button




