As part of the migration, there were some components created under the AWS account. The Nautilus DevOps team created one EC2 instance where they forgot to enable the termination protection which is needed for this instance.

An instance named nautilus-ec2 already exists in us-east-1 region. Enable termination protection for the same.



Use below given AWS Credentials: (You can run the showcreds command on aws-client host to retrieve these credentials)

Console URL	https://959459115696.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_482481
Password	XxR!Ajhlc99%
Start Time	Fri Dec 12 14:51:42 UTC 2025
End Time	Fri Dec 12 15:51:42 UTC 2025

Notes:

Create the resources only in us-east-1 region.

To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:
toggle button
