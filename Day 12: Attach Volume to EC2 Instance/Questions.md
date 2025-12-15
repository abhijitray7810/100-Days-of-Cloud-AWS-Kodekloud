The Nautilus DevOps team has been creating a couple of services on AWS cloud. They have been breaking down the migration into smaller tasks, allowing for better control, risk mitigation, and optimization of resources throughout the migration process. Recently they came up with requirements mentioned below.

An instance named nautilus-ec2 and a volume named nautilus-volume already exists in us-east-1 region. Attach the nautilus-volume volume to the nautilus-ec2 instance, make sure to set the device name to /dev/sdb while attaching the volume.



Use below given AWS Credentials: (You can run the showcreds command on aws-client host to retrieve these credentials)

Console URL	https://022390610537.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_699024
Password	1@BN9T@ig0pU
Start Time	Mon Dec 15 16:59:32 UTC 2025
End Time	Mon Dec 15 17:59:32 UTC 2025
Notes:

Create the resources only in us-east-1 region.

To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:
toggle button




