import io
import os
import re
import gzip
import json
import logging

import boto3


logger = logging.getLogger()
logger.setLevel(logging.INFO)
    
    
def get_tuple(record):
    """
    Turns a CloudTrail record into a tuple of <principal ID, IP address>.
    
    :param record: a CloudTrail record for a single API event
    :return: <principal ID, IP address> tuple
    """
    ip = record['sourceIPAddress']
    principal = record['userIdentity']['principalId'].split(':')[0]
    return principal, ip


def load_cloudtrail_log(s3_client, bucket, key):
    """
    Loads a CloudTrail log file, decompresses it, and extracts its records.

    :param s3_client: Boto3 S3 client
    :param bucket: Bucket where log file is located
    :param key: Key to the log file object in the bucket
    :return: list of CloudTrail records
    """
    response = s3_client.get_object(Bucket=bucket, Key=key)
    logger.info('Loading CloudTrail log file s3://{}/{}'.format(bucket, key))

    with io.BytesIO(response['Body'].read()) as obj:
        with gzip.GzipFile(fileobj=obj) as logfile:
            records = json.load(logfile)['Records']
            sorted_records = sorted(records, key=lambda r: r['eventTime']) 
            logger.info('Number of records in log file: {}'.format(len(sorted_records)))
            return sorted_records
    
    
def print_short_record(record):
    """
    Prints out an abbreviated, one-line representation of a CloudTrail record.
    
    :param record: a CloudTrail record
    """
    print('[{timestamp}] {region}\t{ip}\t{service}:{action}'.format(
        timestamp=record['eventTime'],
        region=record['awsRegion'],
        ip=record['sourceIPAddress'],
        service=record['eventSource'].split('.')[0],
        action=record['eventName']
    ))
    
    
def get_workshop_log_files(s3_client, bucket, prefix=None):
    """
    Loads the list of CloudTrail log files used for the Detection ML workshop
    that are stored in an S3 bucket.
    
    :param s3_client: Boto3 S3 client
    :param bucket: name of the bucket from which to load log files
    :param prefix: prefix within the bucket to search for log files
    :return: tuple of bucket and key name
    """
    res = s3_client.list_objects_v2(
        Bucket=bucket,
        Prefix=prefix,
    )
    
    for obj in res['Contents']:
        if obj['Size'] > 0 and obj['Key'].endswith('gz'):
            key = obj['Key']
            yield bucket, key


def handler(event, context):
    # Load environment variables for input and output locations
    logs_input_bucket = os.environ['INPUT_BUCKET']
    logs_input_prefix = os.environ['INPUT_PREFIX']
    tuples_output_bucket = os.environ['OUTPUT_BUCKET']
    tuples_output_key = os.environ['OUTPUT_KEY']

    # Create a Boto3 session and S3 client
    session = boto3.session.Session()
    s3_client = session.client('s3')
    
    # Get a list of the CloudTrail log files for the workshop
    log_files = [(bucket, key) for bucket, key in get_workshop_log_files(
        s3_client, logs_input_bucket, logs_input_prefix
    )]
    
    tuples = []
    
    for bucket, key in log_files:
        # Load the records from each CloudTrail log file
        records = load_cloudtrail_log(s3_client, bucket, key)
        
        # Process the CloudTrail records
        for record in records:
            if record['sourceIPAddress'].endswith('.amazonaws.com'):
                continue  # Ignore calls coming from AWS service principals
            print_short_record(record)
            
            # TODO - Uncomment next lines to get tuples for each finding
            # principal, ip = get_tuple(record)
            # tuples.append('{},{}'.format(principal, ip))
    
    # Write the tuples to S3 where they can be read by the Sagemaker algorithm
    if len(tuples) > 0:
        logger.info('Writing tuples to s3://%s/%s', 
            tuples_output_bucket, tuples_output_key)
    
        s3_client.put_object(
            Bucket=tuples_output_bucket,
            Key=tuples_output_key,
            ContentType='text/csv',
            Body='\n'.join(tuples),
        ) 
