-- Master CREATE statement for using Cloudtrail logs with Athena
-- This is the same statement you'd see if you go to the CloudTrail console, choose Event History
--   and click the link for "Run advanced queries in Amazon Athena"
-- *NOTE* You must set the s3 bucket LOCATION for your logs
CREATE EXTERNAL TABLE aero_logs_6 (
eventVersion STRING,
userIdentity STRUCT<
type: STRING,
principalId: STRING,
arn: STRING,
accountId: STRING,
invokedBy: STRING,
accessKeyId: STRING,
userName: STRING,
sessionContext: STRUCT<
attributes: STRUCT<
mfaAuthenticated: STRING,
creationDate: STRING>,
sessionIssuer: STRUCT<
type: STRING,
principalId: STRING,
arn: STRING,
accountId: STRING,
userName: STRING>>>,
eventTime STRING,
eventSource STRING,
eventName STRING,
awsRegion STRING,
sourceIpAddress STRING,
userAgent STRING,
errorCode STRING,
errorMessage STRING,
requestParameters STRING,
responseElements STRING,
additionalEventData STRING,
requestId STRING,
eventId STRING,
resources ARRAY<STRUCT<
arn: STRING,
accountId: STRING,
type: STRING>>,
eventType STRING,
apiVersion STRING,
readOnly STRING,
recipientAccountId STRING,
serviceEventDetails STRING,
sharedEventID STRING,
vpcEndpointId STRING
)
COMMENT 'CloudTrail table for aero_logs_6 bucket, with partitions'
PARTITIONED BY(account string, region string,year string, month string)
ROW FORMAT SERDE 'com.amazon.emr.hive.serde.CloudTrailSerde'
STORED AS INPUTFORMAT 'com.amazon.emr.cloudtrail.CloudTrailInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/'      -- *SET THIS LOCATION*
TBLPROPERTIES ('classification'='cloudtrail');

----------------------------------------------------------
--*CUSTOMIZE* this next section for your particular accounts, regions, and dates
----------------------------------------------------------
--Create the partitions on the data we want to be able to query
--For this sample, I chose...
--     4 accounts: '266533154659', '387170699591', '002726030336', '004233244793', 
--     4 regions: 'us-east-1', 'us-east-2', 'us-west-1', 'us-west-2'
--     1 year: 2019
--     6 months: 06, 07, 08, 09, 10, 11
-- That results in 96 partitions created.

ALTER TABLE aero_logs_6 ADD
PARTITION (account='266533154659', region='us-east-1', year='2019', month='06') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-east-1/2019/06/'
PARTITION (account='266533154659', region='us-east-1', year='2019', month='07') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-east-1/2019/07/'
PARTITION (account='266533154659', region='us-east-1', year='2019', month='08') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-east-1/2019/08/'
PARTITION (account='266533154659', region='us-east-1', year='2019', month='09') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-east-1/2019/09/'
PARTITION (account='266533154659', region='us-east-1', year='2019', month='10') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-east-1/2019/10/'
PARTITION (account='266533154659', region='us-east-1', year='2019', month='11') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-east-1/2019/11/'
PARTITION (account='266533154659', region='us-east-2', year='2019', month='06') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-east-2/2019/06/'
PARTITION (account='266533154659', region='us-east-2', year='2019', month='07') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-east-2/2019/07/'
PARTITION (account='266533154659', region='us-east-2', year='2019', month='08') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-east-2/2019/08/'
PARTITION (account='266533154659', region='us-east-2', year='2019', month='09') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-east-2/2019/09/'
PARTITION (account='266533154659', region='us-east-2', year='2019', month='10') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-east-2/2019/10/'
PARTITION (account='266533154659', region='us-east-2', year='2019', month='11') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-east-2/2019/11/'
PARTITION (account='266533154659', region='us-west-1', year='2019', month='06') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-west-1/2019/06/'
PARTITION (account='266533154659', region='us-west-1', year='2019', month='07') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-west-1/2019/07/'
PARTITION (account='266533154659', region='us-west-1', year='2019', month='08') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-west-1/2019/08/'
PARTITION (account='266533154659', region='us-west-1', year='2019', month='09') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-west-1/2019/09/'
PARTITION (account='266533154659', region='us-west-1', year='2019', month='10') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-west-1/2019/10/'
PARTITION (account='266533154659', region='us-west-1', year='2019', month='11') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-west-1/2019/11/'
PARTITION (account='266533154659', region='us-west-2', year='2019', month='06') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-west-2/2019/06/'
PARTITION (account='266533154659', region='us-west-2', year='2019', month='07') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-west-2/2019/07/'
PARTITION (account='266533154659', region='us-west-2', year='2019', month='08') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-west-2/2019/08/'
PARTITION (account='266533154659', region='us-west-2', year='2019', month='09') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-west-2/2019/09/'
PARTITION (account='266533154659', region='us-west-2', year='2019', month='10') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-west-2/2019/10/'
PARTITION (account='266533154659', region='us-west-2', year='2019', month='11') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/266533154659/CloudTrail/us-west-2/2019/11/'
PARTITION (account='387170699591', region='us-east-1', year='2019', month='06') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-east-1/2019/06/'
PARTITION (account='387170699591', region='us-east-1', year='2019', month='07') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-east-1/2019/07/'
PARTITION (account='387170699591', region='us-east-1', year='2019', month='08') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-east-1/2019/08/'
PARTITION (account='387170699591', region='us-east-1', year='2019', month='09') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-east-1/2019/09/'
PARTITION (account='387170699591', region='us-east-1', year='2019', month='10') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-east-1/2019/10/'
PARTITION (account='387170699591', region='us-east-1', year='2019', month='11') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-east-1/2019/11/'
PARTITION (account='387170699591', region='us-east-2', year='2019', month='06') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-east-2/2019/06/'
PARTITION (account='387170699591', region='us-east-2', year='2019', month='07') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-east-2/2019/07/'
PARTITION (account='387170699591', region='us-east-2', year='2019', month='08') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-east-2/2019/08/'
PARTITION (account='387170699591', region='us-east-2', year='2019', month='09') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-east-2/2019/09/'
PARTITION (account='387170699591', region='us-east-2', year='2019', month='10') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-east-2/2019/10/'
PARTITION (account='387170699591', region='us-east-2', year='2019', month='11') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-east-2/2019/11/'
PARTITION (account='387170699591', region='us-west-1', year='2019', month='06') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-west-1/2019/06/'
PARTITION (account='387170699591', region='us-west-1', year='2019', month='07') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-west-1/2019/07/'
PARTITION (account='387170699591', region='us-west-1', year='2019', month='08') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-west-1/2019/08/'
PARTITION (account='387170699591', region='us-west-1', year='2019', month='09') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-west-1/2019/09/'
PARTITION (account='387170699591', region='us-west-1', year='2019', month='10') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-west-1/2019/10/'
PARTITION (account='387170699591', region='us-west-1', year='2019', month='11') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-west-1/2019/11/'
PARTITION (account='387170699591', region='us-west-2', year='2019', month='06') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-west-2/2019/06/'
PARTITION (account='387170699591', region='us-west-2', year='2019', month='07') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-west-2/2019/07/'
PARTITION (account='387170699591', region='us-west-2', year='2019', month='08') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-west-2/2019/08/'
PARTITION (account='387170699591', region='us-west-2', year='2019', month='09') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-west-2/2019/09/'
PARTITION (account='387170699591', region='us-west-2', year='2019', month='10') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-west-2/2019/10/'
PARTITION (account='387170699591', region='us-west-2', year='2019', month='11') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/387170699591/CloudTrail/us-west-2/2019/11/'
PARTITION (account='002726030336', region='us-east-1', year='2019', month='06') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-east-1/2019/06/'
PARTITION (account='002726030336', region='us-east-1', year='2019', month='07') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-east-1/2019/07/'
PARTITION (account='002726030336', region='us-east-1', year='2019', month='08') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-east-1/2019/08/'
PARTITION (account='002726030336', region='us-east-1', year='2019', month='09') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-east-1/2019/09/'
PARTITION (account='002726030336', region='us-east-1', year='2019', month='10') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-east-1/2019/10/'
PARTITION (account='002726030336', region='us-east-1', year='2019', month='11') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-east-1/2019/11/'
PARTITION (account='002726030336', region='us-east-2', year='2019', month='06') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-east-2/2019/06/'
PARTITION (account='002726030336', region='us-east-2', year='2019', month='07') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-east-2/2019/07/'
PARTITION (account='002726030336', region='us-east-2', year='2019', month='08') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-east-2/2019/08/'
PARTITION (account='002726030336', region='us-east-2', year='2019', month='09') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-east-2/2019/09/'
PARTITION (account='002726030336', region='us-east-2', year='2019', month='10') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-east-2/2019/10/'
PARTITION (account='002726030336', region='us-east-2', year='2019', month='11') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-east-2/2019/11/'
PARTITION (account='002726030336', region='us-west-1', year='2019', month='06') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-west-1/2019/06/'
PARTITION (account='002726030336', region='us-west-1', year='2019', month='07') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-west-1/2019/07/'
PARTITION (account='002726030336', region='us-west-1', year='2019', month='08') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-west-1/2019/08/'
PARTITION (account='002726030336', region='us-west-1', year='2019', month='09') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-west-1/2019/09/'
PARTITION (account='002726030336', region='us-west-1', year='2019', month='10') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-west-1/2019/10/'
PARTITION (account='002726030336', region='us-west-1', year='2019', month='11') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-west-1/2019/11/'
PARTITION (account='002726030336', region='us-west-2', year='2019', month='06') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-west-2/2019/06/'
PARTITION (account='002726030336', region='us-west-2', year='2019', month='07') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-west-2/2019/07/'
PARTITION (account='002726030336', region='us-west-2', year='2019', month='08') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-west-2/2019/08/'
PARTITION (account='002726030336', region='us-west-2', year='2019', month='09') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-west-2/2019/09/'
PARTITION (account='002726030336', region='us-west-2', year='2019', month='10') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-west-2/2019/10/'
PARTITION (account='002726030336', region='us-west-2', year='2019', month='11') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/002726030336/CloudTrail/us-west-2/2019/11/'
PARTITION (account='004233244793', region='us-east-1', year='2019', month='06') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-east-1/2019/06/'
PARTITION (account='004233244793', region='us-east-1', year='2019', month='07') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-east-1/2019/07/'
PARTITION (account='004233244793', region='us-east-1', year='2019', month='08') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-east-1/2019/08/'
PARTITION (account='004233244793', region='us-east-1', year='2019', month='09') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-east-1/2019/09/'
PARTITION (account='004233244793', region='us-east-1', year='2019', month='10') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-east-1/2019/10/'
PARTITION (account='004233244793', region='us-east-1', year='2019', month='11') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-east-1/2019/11/'
PARTITION (account='004233244793', region='us-east-2', year='2019', month='06') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-east-2/2019/06/'
PARTITION (account='004233244793', region='us-east-2', year='2019', month='07') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-east-2/2019/07/'
PARTITION (account='004233244793', region='us-east-2', year='2019', month='08') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-east-2/2019/08/'
PARTITION (account='004233244793', region='us-east-2', year='2019', month='09') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-east-2/2019/09/'
PARTITION (account='004233244793', region='us-east-2', year='2019', month='10') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-east-2/2019/10/'
PARTITION (account='004233244793', region='us-east-2', year='2019', month='11') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-east-2/2019/11/'
PARTITION (account='004233244793', region='us-west-1', year='2019', month='06') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-west-1/2019/06/'
PARTITION (account='004233244793', region='us-west-1', year='2019', month='07') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-west-1/2019/07/'
PARTITION (account='004233244793', region='us-west-1', year='2019', month='08') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-west-1/2019/08/'
PARTITION (account='004233244793', region='us-west-1', year='2019', month='09') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-west-1/2019/09/'
PARTITION (account='004233244793', region='us-west-1', year='2019', month='10') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-west-1/2019/10/'
PARTITION (account='004233244793', region='us-west-1', year='2019', month='11') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-west-1/2019/11/'
PARTITION (account='004233244793', region='us-west-2', year='2019', month='06') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-west-2/2019/06/'
PARTITION (account='004233244793', region='us-west-2', year='2019', month='07') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-west-2/2019/07/'
PARTITION (account='004233244793', region='us-west-2', year='2019', month='08') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-west-2/2019/08/'
PARTITION (account='004233244793', region='us-west-2', year='2019', month='09') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-west-2/2019/09/'
PARTITION (account='004233244793', region='us-west-2', year='2019', month='10') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-west-2/2019/10/'
PARTITION (account='004233244793', region='us-west-2', year='2019', month='11') LOCATION 's3://rein2019-builder-cloudtrail-1/AWSLogs/o-dzechg70s9/004233244793/CloudTrail/us-west-2/2019/11/';


--------------------
-- SAMPLE QUERIES --
--------------------

----------------------------------------------------------
--*CUSTOMIZE* this next section for your particular accounts, regions, dates, Users, and API (eventname) of interest
--The important part of these queries is the WHERE clauses that limit the data scans to manageable run times
----------------------------------------------------------

--Count entries for a particular (partitioned) account, region, month
select count(*)
from aero_logs_6
where account='266533154659'and region='us-east-1' and month='07';

--Get a frequency distribution of eventnames for a particular (partitioned) account, region, month
select eventname, count(*) as frequency
from aero_logs_6
where account='266533154659'and region='us-east-1'and month='07'
group by eventname
order by count(*) desc;

--Count how many times a particular eventname (prefix) occurs in any of the 5 (partitioned) accounts, 1 region, 1 month
select count(*) as frequency
from aero_logs_6
where account in ('266533154659', '387170699591', '002726030336', '004233244793')
  and region='us-east-1'
  and month='07'
  and eventname like 'CreateUser%';

--Get a list with some details of CreateUser calls in any (partitioned) account for 1 region, 1 month
select account, eventtime, eventsource, eventname, userIdentity.arn
from aero_logs_6
where account in ('266533154659', '387170699591', '002726030336', '004233244793')
  and region='us-east-1'
  and month='07'
  and eventname like 'CreateUser%'
order by account, eventtime;

--Same query, but included a date range to get a particular week in July
--Note: Still included the month='07' filter because it speeds up the query 
select account, eventtime, eventsource, eventname, userIdentity.arn
from aero_logs_6
where account in ('266533154659', '387170699591', '002726030336', '004233244793')
  and region='us-east-1'
  and month='07'
  and from_iso8601_timestamp(eventtime) BETWEEN date '2019-07-01' AND date '2019-07-07'
  and eventname like 'CreateUser%'
order by account, eventtime;

--Finally, let's pull a data set for further exploration and modeling in pythong
select eventtime, useridentity.arn, eventname
from aero_logs_6
where account in ('002726030336', '004233244793')
and region in ('us-east-1', 'us-east-2', 'us-west-1', 'us-west-2');
