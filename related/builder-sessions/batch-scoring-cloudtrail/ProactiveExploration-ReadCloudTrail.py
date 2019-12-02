import io
import os
import re
import gzip
import json
import logging
import boto3

# enable logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)
    
    
def get_tuple(record):
    """
    Turns a CloudTrail record into a tuple of <UserIdentity -> arn, eventTime, eventName>.
    
    :param record: a CloudTrail record for a single API event
    :return: <principal ID, IP address> tuple
    """
    arn = record['userIdentity']['arn']
    timestamp = record['eventTime']
    event = record['eventName']
    return timestamp, event, arn


def load_cloudtrail_log(s3_client, bucket, key):
    """
    Loads a CloudTrail log file, decompresses it, and extracts its records.

    :param s3_client: Boto3 S3 client
    :param bucket: Bucket where log file is located
    :param key: Key to the log file object in the bucket
    :return: list of CloudTrail records
    """
    response = s3_client.get_object(Bucket=bucket, Key=key)
    # logger.info('Loading CloudTrail log file s3://{}/{}'.format(bucket, key))

    with io.BytesIO(response['Body'].read()) as obj:
        with gzip.GzipFile(fileobj=obj) as logfile:
            records = json.load(logfile)['Records']
            sorted_records = sorted(records, key=lambda r: r['eventTime']) 
            # logger.info('Number of records in log file: {}'.format(len(sorted_records)))
            return sorted_records
    

    
    
def get_workshop_log_files(s3_client, bucket, prefix=None):
    """
    Loads the list of CloudTrail log files used for the Detection ML workshop
    that are stored in an S3 bucket.
    
    :param s3_client: Boto3 S3 client
    :param bucket: name of the bucket from which to load log files
    :param prefix: prefix within the bucket to search for log files
    :param maxkeys: limit the number of files retrieved from S3 - this will directly
    :               impact the lambda function execution time and number of CloudTrail entries
    :               retrive for one day. max = 1000
    :return: tuple of bucket and key name
    """
    res = s3_client.list_objects_v2(
        Bucket=bucket,
        Prefix=prefix,
        MaxKeys=100
    )
    
    for obj in res['Contents']:
        if obj['Size'] > 0 and obj['Key'].endswith('gz'):
            key = obj['Key']
            yield bucket, key


def handler(event, context):
    # Load environment variables
    tuples_output_bucket = os.environ['OUTPUT_BUCKET']
    tuples_output_key = os.environ['OUTPUT_KEY']
   
    # Load event parameters
    logs_input_bucket = event['cloudtrail_bucket']
    logs_aws_account = event['aws_account']
    logs_aws_region = event['aws_region']
    logs_day = event['day_of_interest']
    
    # constructs key for CloudTrail file
    logs_input_prefix = 'AWSLogs/'+logs_aws_account+'/CloudTrail/'+logs_aws_region+'/'+logs_day
    
    # Create a Boto3 session and S3 client
    session = boto3.session.Session()
    s3_client = session.client('s3')
    
    # Get a list of the CloudTrail log files
    log_files = [(bucket, key) for bucket, key in get_workshop_log_files(
        s3_client, logs_input_bucket, logs_input_prefix
    )]
    
    tuples = []
    
    n = 0
    
    for bucket, key in log_files:
        # Load the records from each CloudTrail log file
        records = load_cloudtrail_log(s3_client, bucket, key)
        
        # Process the CloudTrail records
        for record in records:
            n = n + 1
            if record['sourceIPAddress'].endswith('.amazonaws.com'):
                continue  # Ignore calls coming from AWS service principals

            try:
                timestamp, event, arn = get_tuple(record)
                tuples.append('{},{},{}'.format(timestamp, event, arn))
            except:
                logger.info('Error loading record #{}'.format(n))
                logger.info(record)
            
            # Write the tuples to S3 where they can be read by the Sagemaker algorithm
            if len(tuples) > 0:
                s3_client.put_object(
                    Bucket=tuples_output_bucket,
                    Key=tuples_output_key,
                    ContentType='text/csv',
                    Body='\n'.join(tuples),
                )
    logger.info('Processed {} records'.format(n))
    return {
        'cloudtrail_bucket':logs_input_bucket,
        'cloudtrail_key':logs_input_prefix,
        'aws_account':logs_aws_account,
        'aws_region':logs_aws_region,
        'day_of_interest':logs_day,
        'tuples_bucket':tuples_output_bucket, 
        'tuples_key':tuples_output_key
    }

