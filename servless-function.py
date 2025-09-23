import json
import boto3
import logging
from datetime import datetime

# Configura logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Inicializa SNS client
sns_client = boto3.client('sns')
SNS_TOPIC_ARN = "arn:aws:sns:us-east-1:123456789012:MyTopic"

def lambda_handler(event, context):
    """
    Lambda triggered by S3 upload event.
    Logs structured info and sends SNS notification.
    """
    # Processa o evento S3
    for record in event.get('Records', []):
        bucket_name = record['s3']['bucket']['name']
        object_key = record['s3']['object']['key']
        event_time = record['eventTime']

        # Cria log estruturado
        log_entry = {
            "event": "S3ObjectCreated",
            "bucket": bucket_name,
            "object_key": object_key,
            "timestamp": event_time
        }
        logger.info(json.dumps(log_entry))

        # Envia notificação via SNS
        message = {
            "subject": "Novo arquivo no bucket S3",
            "body": log_entry
        }
        sns_client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject=message["subject"],
            Message=json.dumps(message["body"])
        )

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Processed successfully", "records": len(event.get('Records', []))})
    }
