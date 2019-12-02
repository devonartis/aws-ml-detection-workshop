import io
import os
import logging
import boto3
import random

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    logger.info(event)
    # Load event variables
    logs_input_bucket = event['cloudtrail_bucket']
    logs_input_prefix = event['cloudtrail_key']
    logs_aws_account = event['aws_account']
    logs_aws_region = event['aws_region']
    logs_day = event['day_of_interest']
    insights_output_bucket = event['insights_bucket']
    insights_output_key = event['insights_key']

    # Load environment variables
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    insight_threshold = float(os.environ['INSIGHT_THRESHOLD'])
    # Create SNS client to publish to topic
    sns_client = boto3.client('sns')
   
    # Create a Boto3 resource and download CSV
    session = boto3.session.Session()
    s3_client = session.client('s3')
    obj = s3_client.get_object(Bucket=insights_output_bucket, Key=insights_output_key)
    body = obj["Body"].read()
    body_decoded = body.decode("utf-8")
    tuples = body_decoded.split('\n')
    n = 0
    a = 0
    # If insight is higher than threshold, publish alert in SNS topic
    for tuple in tuples:
        n = n + 1
        arn, action, count, insight = tuple.split(',')
        if float(insight) > insight_threshold:
            response = sns_client.publish(
                TopicArn=sns_topic_arn,
                Message='Possible malicious activity detected\n\n ACCOUNT={}\nREGION={}\nDAY={}\nARN={}\nACTION={}\nCOUNT={}\nINSIGHT={}\nCLOUDTRAIL={}'.format(
                    logs_aws_account, logs_aws_region, logs_day, arn, action, count, insight, logs_input_prefix)
            )
            a = a + 1
        # logger.info(response)
    
    logger.info('Processed {} records'.format(n))
    logger.info('Sent {} alerts to SNS'.format(a))

    return None



ß