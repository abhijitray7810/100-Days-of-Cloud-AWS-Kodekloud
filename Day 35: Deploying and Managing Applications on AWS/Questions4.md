The Nautilus DevOps team needs a new private RDS instance for their application. They need to set up a MySQL database and ensure that their existing EC2 instance can connect to it. This will help in managing their database needs efficiently and securely.

1) Task Details:

Create a private RDS instance named xfusion-rds using a sandbox template.
The engine type must be MySQL v8.4.5, and it must be a db.t3.micro type instance.
The master username must be xfusion_admin with an appropriate password.
The RDS storage type must be gp2, and the storage size must be 5GiB.
Create a database named xfusion_db.
Keep the rest of the configurations as default. Ensure the instance is in available state.
Adjust the security groups so that the xfusion-ec2 instance can connect to the RDS on port 3306 and also open port 80 for the instance.
2) An EC2 instance named xfusion-ec2 exists. Connect to this instance from the AWS console. Create an SSH key (/root/.ssh/id_rsa) on the aws-client host if it doesn't already exist. Add the public key to the authorized keys of the root user on the EC2 instance for password-less SSH access.

3) There is a file named index.php under the /root directory on the aws-client host. Copy this file to the xfusion-ec2 instance under the /var/www/html/ directory. Make the appropriate changes in the file to connect to the RDS.

4) You should see a Connected successfully message in the browser once you access the instance using the public IP.


Use the below given AWS Credentials: (You can run the showcreds command on the aws-client host to retrieve these credentials)

Console URL	https://858459473012.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_200620
Password	d92I90fCWT%N
Start Time	Sat Jan 17 11:57:40 UTC 2026
End Time	Sat Jan 17 12:57:40 UTC 2026
Notes:

Create the resources only in the us-east-1 region.
To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:
toggle button



