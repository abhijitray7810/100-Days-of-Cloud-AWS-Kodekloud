The Nautilus DevOps Team has received a new request from the Development Team to set up a new EC2 instance. This instance will be used to host a new application that requires a stable IP address. To ensure that the instance has a consistent public IP, an Elastic IP address needs to be associated with it. The instance will be named nautilus-ec2, and the Elastic IP will be named nautilus-eip. This setup will help the Development Team to have a reliable and consistent access point for their application.

Create an EC2 instance named nautilus-ec2 using any linux AMI like ubuntu, the Instance type must be t2.micro and associate an Elastic IP address with this instance, name it as nautilus-eip.


Use below given AWS Credentials: (You can run the showcreds command on aws-client host to retrieve these credentials)

Console URL	https://047198242333.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_196948
Password	DGB^p^9@ocKt
Start Time	Wed Dec 17 13:58:17 UTC 2025
End Time	Wed Dec 17 14:58:17 UTC 2025

Notes:

Create the resources only in us-east-1 region.

To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:
toggle button
