import io
import os
import logging
import boto3
import random

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def getinsight(arn, action, count):
    """
    Calculates insight for CloudTrail tuple <<UserIdentity -> arn, eventName, Count of EventName>
    
    :param arn: CloudTrail UserIdentity -> arn
    :param action: CloudTrail eventName
    :param count: Count of eventName aggregated by ProactiveExploration-ReadCloudTrail.py
    :return: insight - index calculated by model
    """
    # TO-DO NEAL ROTHLEDER
    # add code to submit to sagemaker model
    # random function generating positive float < 1
    result = random.random()
    return result

def handler(event, context):
    logger.info(event)
    # Load environment variables
    insights_output_bucket = os.environ['OUTPUT_BUCKET']
    insights_output_key = os.environ['OUTPUT_KEY']
  
    # Load event variables
    logs_input_bucket = event['cloudtrail_bucket']
    logs_input_prefix = event['cloudtrail_key']
    logs_aws_account = event['aws_account']
    logs_aws_region = event['aws_region']
    logs_day = event['day_of_interest']
    tuples_input_bucket = event['tuples_bucket']
    tuples_input_key = event['tuples_key']
    
    # Create a Boto3 resource and download CSV with CloudTrail actions aggregate
    session = boto3.session.Session()
    s3_client = session.client('s3')
    obj = s3_client.get_object(Bucket=tuples_input_bucket, Key=tuples_input_key)
    body = obj["Body"].read()
    body_decoded = body.decode("utf-8")
    tuples = body_decoded.split('\n')
    n = 0
    aggregate = {}
    
    for tuple in tuples:
        # aggregate arn by action with count
        n = n + 1
        date, action, arn = tuple.split(',')
        if arn in aggregate.keys():
            try:
                aggregate[arn][action] = aggregate[arn][action] + 1
            except:
                aggregate[arn].update({action:1})
        else:
            aggregate[arn] = {action:1}
    
    logger.info('Processed {} records'.format(n))
    
    insights = []

    # create CSV file in S3 with calculated insight
    # CSV format contains arn, action, count of action, insight
    for arn, actions in aggregate.items():
        for action in actions:
            insight = getinsight(arn, action, actions[action])
            insights.append('{},{},{},{}'.format(arn, action, actions[action],insight))
            s3_client.put_object(
                Bucket=insights_output_bucket,
                Key=insights_output_key,
                ContentType='text/csv',
                Body='\n'.join(insights)
            )

    return {
        'cloudtrail_bucket':logs_input_bucket,
        'cloudtrail_key':logs_input_prefix,
        'aws_account':logs_aws_account,
        'aws_region':logs_aws_region,
        'day_of_interest':logs_day,
        'insights_bucket':insights_output_bucket, 
        'insights_key':insights_output_key
    }
