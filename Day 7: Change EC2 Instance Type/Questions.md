During the migration process, the Nautilus DevOps team created several EC2 instances in different regions. They are currently in the process of identifying the correct resources and utilization and are making continuous changes to ensure optimal resource utilization. Recently, they discovered that one of the EC2 instances was underutilized, prompting them to decide to change the instance type. Please make sure the Status check is completed (if its still in Initializing state) before making any changes to the instance.

1) Change the instance type from t2.micro to t2.nano for devops-ec2 instance.

2) Make sure the ec2 instance devops-ec2 is in running state after the change.



Use below given AWS Credentials: (You can run the showcreds command on aws-client host to retrieve these credentials)

Console URL	https://480470673558.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_214768
Password	EJQ6ZUPRB^d9
Start Time	Wed Dec 10 18:18:34 UTC 2025
End Time	Wed Dec 10 19:18:34 UTC 2025

Notes:

Create the resources only in us-east-1 region.

To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:
toggle button
