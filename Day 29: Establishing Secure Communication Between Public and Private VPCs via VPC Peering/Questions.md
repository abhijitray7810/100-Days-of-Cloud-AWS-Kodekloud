The Nautilus DevOps team has been tasked with demonstrating the use of VPC Peering to enable communication between two VPCs. One VPC will be a private VPC that contains a private EC2 instance, while the other will be the default public VPC containing a publicly accessible EC2 instance.

1) There is already an existing EC2 instance in the public vpc/subnet:

Name: xfusion-public-ec2
2) There is already an existing Private VPC:

Name: xfusion-private-vpc
CIDR: 10.1.0.0/16
3) There is already an existing Subnet in xfusion-private-vpc:

Name: xfusion-private-subnet
CIDR: 10.1.1.0/24
4) There is already an existing EC2 instance in the private subnet:

Name: xfusion-private-ec2
5) Create a Peering Connection between the Default VPC and the Private VPC:

VPC Peering Connection Name: xfusion-vpc-peering
6) Configure Route Tables to enable communication between the two VPCs.

Ensure the private EC2 instance is accessible from the public EC2 instance.
7) Test the Connection:

Add /root/.ssh/id_rsa.pub public key to the public EC2 instance's ec2-user's authorized_keys to make sure we are able to ssh into this instance from AWS client host. You may also need to update the security group of the private EC2 instance to allow ICMP traffic from the public/default VPC CIDR. This will enable you to ping the private instance from the public instance.
SSH into the public EC2 instance and ensure that you can ping the private EC2 instance.

Use below given AWS Credentials: (You can run the showcreds command on aws-client host to retrieve these credentials)

Console URL	https://402207565198.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_346079
Password	RLjF3^BevC!6
Start Time	Thu Dec 25 06:13:26 UTC 2025
End Time	Thu Dec 25 07:13:26 UTC 2025

Notes:

Create the resources only in us-east-1 region.

To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:
toggle button
