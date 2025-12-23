The Nautilus DevOps team has been tasked with setting up an EC2 instance for their application. To ensure the application performs optimally, they also need to create a CloudWatch alarm to monitor the instance's CPU utilization. The alarm should trigger if the CPU utilization exceeds 90% for one consecutive 5-minute period. To send notifications, use the SNS topic named datacenter-sns-topic which is already created.

Launch EC2 Instance: Create an EC2 instance named datacenter-ec2 using any appropriate Ubuntu AMI.

Create CloudWatch Alarm: Create a CloudWatch alarm named datacenter-alarm with the following specifications:

Statistic: Average
Metric: CPU Utilization
Threshold: >= 90% for 1 consecutive 5-minute period.
Alarm Actions: Send a notification to datacenter-sns-topic.

Use below given AWS Credentials: (You can run the showcreds command on aws-client host to retrieve these credentials)

Console URL	https://465128954904.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_645808
Password	a7@Bc8!uH3%1
Start Time	Tue Dec 23 15:52:00 UTC 2025
End Time	Tue Dec 23 16:52:00 UTC 2025

Notes:

Create the resources only in us-east-1 region.

To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:
toggle button write readme.md file 




