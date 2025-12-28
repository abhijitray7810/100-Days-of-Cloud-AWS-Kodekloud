The Nautilus Development Team is preparing for a major update to their database infrastructure. To ensure a smooth transition and to safeguard data, the team has requested the DevOps team to take a snapshot of the current RDS instance and restore it to a new instance. This process is crucial for testing and validation purposes before the update is rolled out to the production environment. The snapshot will serve as a backup, and the new instance will be used to verify that the backup process works correctly and that the application can function seamlessly with the restored data.

As a member of the Nautilus DevOps Team, your task is to perform the following:

Take a Snapshot: Take a snapshot of the datacenter-rds RDS instance and name it datacenter-snapshot (please wait datacenter-rds instance to be in available state).

Restore the Snapshot: Restore the snapshot to a new RDS instance named datacenter-snapshot-restore.

Configure the New RDS Instance: Ensure that the new RDS instance has a class of db.t3.micro.

Verify the New RDS Instance: The new RDS instance must be in the Available state upon completion of the restoration process.




Use below given AWS Credentials: (You can run the showcreds command on aws-client host to retrieve these credentials)

Console URL	https://047198242333.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_680235
Password	nYtpulCqqt1t
Start Time	Sun Dec 28 14:05:06 UTC 2025
End Time	Sun Dec 28 15:05:06 UTC 2025

Notes:

Create the resources only in us-east-1 region.

To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:
toggle button




