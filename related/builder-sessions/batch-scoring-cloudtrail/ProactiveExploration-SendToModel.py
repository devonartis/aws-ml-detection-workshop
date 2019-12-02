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
    # CODE TO INVOKE ENDPOINT AND GENERATE A SCORE
    # For a full production system, in order to be most accurate, 
    #   we need to rescale the inputs to fit the model training.
    # We'll skip today for our demo.  The python for doing the scaling
    #   can be found in the modeling notebook, and we will update this lambda
    #   function in the github repo after re:Invent
    
    # Our simpfile.csv is just a file with two numbers - invoke_endpoing for this model
    #    likes file objects to read
    # payload = pd.read_csv('simpfile.csv')
    # payload_file = io.StringIO()
    # payload.to_csv(payload_file, header = None, index = None)
    # client = boto3.client('sagemaker-runtime')
    # response = client.invoke_endpoint(
    # EndpointName = 'XXXXXX <<FILL IN ENDPOINT NAME>> XXXXXXXXXXXXXX', 
        # ContentType = 'text/csv',
        # Body = payload_file.getvalue())
    # result = json.loads(response['Body'].read().decode())
    
    # FOR demo purposes, we'll just generate a float [0..1]
    result = random.random()
    return result

def lambda_handler(event, context):
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
