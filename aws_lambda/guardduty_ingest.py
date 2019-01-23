import io
import os
import re
import gzip
import json
import logging

import boto3


logger = logging.getLogger()
logger.setLevel(logging.INFO)


def _extract_source_ips(finding, key_in_additional_info=None):
    """
    Extracts source IP addresses from a GuardDuty finding.

    https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings.html

    :param finding: a GuardDuty finding
    :param key_in_additional_info: key name in 'additionalInfo' field for extraction
    :return: collection of source IP addresses
    """
    source_ips = set()
    service = finding['service']

    if service['action']['actionType'] == 'AWS_API_CALL':
        source_ips.add(service['action']['awsApiCallAction']['remoteIpDetails']['ipAddressV4'])
    elif service['action']['actionType'] == 'NETWORK_CONNECTION':
        source_ips.add(service['action']['networkConnectionAction']['remoteIpDetails']['ipAddressV4'])
    elif service['action']['actionType'] == 'PORT_PROBE':
        source_ips.add(service['action']['portProbeAction']['portProbeDetails'][0]['remoteIpDetails']['ipAddressV4'])

    for item in service.get('additionalInfo', {}).get(key_in_additional_info, []):
        if item.get('ipAddressV4'):
            source_ips.add(item['ipAddressV4'])

    return source_ips
    
    
def get_tuples(finding):
    """
    Turns a GuardDuty finding into a tuple of <principal ID, IP address>
    for each source IP address in the finding.
    
    :param finding: a GuardDuty finding
    :return: list of <principal ID, IP address> tuples
    """
    tuples = []

    if 'accessKeyDetails' in finding['resource']:
        for ip in _extract_source_ips(finding):
            if ip.endswith('.amazonaws.com'):
                continue  # Ignore calls coming from AWS service principals
            principal = finding['resource']['accessKeyDetails']['principalId']
            tuples.append('{},{}'.format(principal, ip))

    return tuples


def print_short_finding(finding):
    """
    Prints out an abbreviated, one-line representation of a GuardDuty finding.
    
    :param finding: a GuardDuty finding
    """
    for ip in _extract_source_ips(finding):
        print('[{timestamp}] {region}\t{ip}\t{type}\t{id}'.format(
            timestamp=finding['updatedAt'],
            region=finding['region'],
            ip=ip,
            type=finding['type'],
            id=finding['id']
        ))


def print_full_finding(finding):
    """
    Prints a GuardDuty finding with sorted and indented fields.
    
    :param finding: a GuardDuty finding
    """
    print(json.dumps(finding, sort_keys=True, indent=4))
    

def load_workshop_findings(s3_client, bucket, prefix):
    """
    This function loads the GuardDuty findings used for the Detection ML workshop.
    that are stored in a JSON file in S3.
    
    :param s3_client: Boto3 S3 client
    :param bucket: name of the bucket from which to load log files
    :param prefix: prefix within the bucket to search for log files
    :return: list of GuardDuty finding dict
    """
    res = s3_client.list_objects_v2(
        Bucket=bucket,
        Prefix=prefix,
    )

    findings = []

    for obj in res['Contents']:
        if obj['Size'] > 0 and obj['Key'].endswith('.json'):
            key = obj['Key']
            logger.info('Loading GuardDuty findings file s3://%s/%s', bucket, key)
            response = s3_client.get_object(Bucket=bucket, Key=key)
            new_findings = json.loads(response['Body'].read())
            logger.info('Number of findings in file: %d', len(new_findings))
            findings.extend(new_findings)

    return findings
    

def handler(event, context):
    # Load environment variables for input and output locations
    findings_input_bucket = os.environ['INPUT_BUCKET']
    findings_input_prefix = os.environ['INPUT_PREFIX']
    tuples_output_bucket = os.environ['OUTPUT_BUCKET']
    tuples_output_key = os.environ['OUTPUT_KEY']

    # Create a Boto3 session and S3 client
    session = boto3.session.Session()
    s3_client = session.client('s3')

    tuples = []

    # Load the GuardDuty findings for the workshop
    findings = load_workshop_findings(s3_client, findings_input_bucket, findings_input_prefix)
    
    # Process the GuardDuty findings
    for finding in findings:
        # TODO - Change to print_short_finding(finding)
        print_full_finding(finding)
        
        # TODO - Uncomment next line to get tuples for each finding
        # tuples.extend(get_tuples(finding))

    # Write the tuples to S3 where they can be read by the Sagemaker algorithm
    if len(tuples) > 0:
        logger.info('Writing tuples to s3://%s/%s', tuples_output_bucket, tuples_output_key)

        s3_client.put_object(
            Bucket=tuples_output_bucket,
            Key=tuples_output_key,
            ContentType='text/csv',
            Body='\n'.join(tuples),
        )
