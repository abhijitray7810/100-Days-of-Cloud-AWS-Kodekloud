The Nautilus DevOps team has been creating a couple of services on AWS cloud. They have been breaking down the migration into smaller tasks, allowing for better control, risk mitigation, and optimization of resources throughout the migration process. Recently they came up with requirements mentioned below.

An instance named xfusion-ec2 and an elastic network interface named xfusion-eni already exists in us-east-1 region.

Attach the xfusion-eni network interface to the xfusion-ec2 instance.
Make sure status is attached before submitting the task.
Please make sure instance initialisation has been completed before submitting this task.



Use below given AWS Credentials. (You can run the showcreds command on aws-client host to retrieve these credentials)

Console URL	https://584135479676.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_824754
Password	CYKFf8J1uCM3
Start Time	Fri Dec 12 15:34:08 UTC 2025
End Time	Fri Dec 12 16:34:08 UTC 2025

Notes:

Create the resources only in us-east-1 region.

To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:
toggle button
