The Nautilus DevOps team is developing a simple 'To-Do' application using DynamoDB to store and manage tasks efficiently. The team needs to create a DynamoDB table to hold tasks, each identified by a unique task ID. Each task will have a description and a status, which indicates the progress of the task (e.g., 'completed' or 'in-progress').

Your task is to:

Create a DynamoDB table named xfusion-tasks with a primary key called taskId (string).
Insert the following tasks into the table:
Task 1: taskId: '1', description: 'Learn DynamoDB', status: 'completed'
Task 2: taskId: '2', description: 'Build To-Do App', status: 'in-progress'
Verify that Task 1 has a status of 'completed' and Task 2 has a status of 'in-progress'.
Ensure the DynamoDB table is created successfully and that both tasks are inserted correctly with the appropriate statuses.


Use below given AWS Credentials: (You can run the showcreds command on aws-client host to retrieve these credentials)

Console URL	https://826068004857.signin.aws.amazon.com/console?region=us-east-1
Username	kk_labs_user_382548
Password	dD8%@7576ux%
Start Time	Wed Jan 28 04:48:13 UTC 2026
End Time	Wed Jan 28 05:48:13 UTC 2026

Notes:

Create the resources only in us-east-1 region.

To display or hide the terminal of the AWS client machine, you can use the expand toggle button as shown below:
toggle button
