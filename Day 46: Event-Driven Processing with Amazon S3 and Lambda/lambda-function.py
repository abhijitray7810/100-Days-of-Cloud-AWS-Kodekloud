import json
import boto3
from datetime import datetime
import uuid

# Initialize the S3 and DynamoDB clients
s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('devops-S3CopyLogs')

def lambda_handler(event, context):
    try:
        # Get the source bucket and object key from the event
        source_bucket = event['Records'][0]['s3']['bucket']['name']
        object_key = event['Records'][0]['s3']['object']['key']

        # Hardcoded destination bucket name
        destination_bucket = "devops-private-27007"

        print(f"[INFO] Source bucket: {source_bucket}, Object key: {object_key}")
        print(f"[INFO] Destination bucket: {destination_bucket}")

        # Copy object
        copy_source = {
            'Bucket': source_bucket,
            'Key': object_key
        }

        s3.copy_object(
            CopySource=copy_source,
            Bucket=destination_bucket,
            Key=object_key
        )

        print(f"[INFO] File successfully copied")

        # Create log entry
        log_entry = {
            'LogID': str(uuid.uuid4()),
            'SourceBucket': source_bucket,
            'DestinationBucket': destination_bucket,
            'ObjectKey': object_key,
            'Timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'Status': 'Success'
        }

        table.put_item(Item=log_entry)

        return {
            'statusCode': 200,
            'body': json.dumps(f"File successfully copied to {destination_bucket}")
        }

    except Exception as e:

        log_entry = {
            'LogID': str(uuid.uuid4()),
            'SourceBucket': source_bucket,
            'DestinationBucket': destination_bucket,
            'ObjectKey': object_key,
            'Timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'Status': 'Failure',
            'Error': str(e)
        }

        table.put_item(Item=log_entry)

        return {
            'statusCode': 500,
            'body': json.dumps(f"Error copying file: {str(e)}")
        }
