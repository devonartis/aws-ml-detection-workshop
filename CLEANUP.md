# Cleaning up

**NOTE: These steps only are needed if you've deployed the CloudFormation stack to your own AWS account and want to clean things up afterwards (e.g., to not be billed for the resources used). If you've used the AWS Jam Platform for the workshop, you do not need to perform any clean-up steps.**

## Overview

In order to prevent charges to your account from the resources created during this workshop, we recommend cleaning up the infrastructure that was created by deleting the CloudFormation stack. You can leave things running though if you want to do more with the workshop; the following cleanup steps can be performed at any time.

# Auto clean-up with Bash script

We've created a Bash script to delete the CloudFormation stack, which will remove the Lambda functions, IAM role, and S3 bucket. We use a script because the S3 bucket has The script, `cleanup.sh`, is provided in this repository.

[Click here](https://github.com/aws-samples/aws-ml-detection-workshop) to go to the repository, then download the script `cleanup.sh` and run it as follows:

```
chmod +x cleanup.sh
./cleanup.sh
```

If you are using a different AWS CLI profile than the default, you can specify it with the `-p PROFILE` parameter to the script, like `cleanup.sh -p foo`.

# Manual clean-up steps

If you cannot run the Bash script, you can manually clean-up these resources by the following steps:

1. Go to the S3 console and delete the bucket whose name ends with "aws-secml-detection-tuplesbucket".
2. Delete the CloudFormation stack by going to the CloudFormation console, selecting the stack called **AWS-SecML-Detection**, and from the top menu choosing action **Delete Stack**. This step will fail if you haven't deleted the S3 bucket first.

You will also need to turn off or remove the following resources. If you wish to retain the resources in your account but not incur charges, you may stop or suspend; otherwise you should disable or delete them.

- GuardDuty ([pricing info](https://aws.amazon.com/guardduty/pricing/))
    - Go to the GuardDuty console, go to **Settings**, then scroll down and choose either **Suspend GuardDuty** or **Disable GuardDuty**.
- SageMaker ([pricing info](https://aws.amazon.com/sagemaker/pricing/))
    - Notebook - On the **Notebook instances** page in the SageMaker console, click the circle to select the "AWS-SecML-Detection" notebook then under **Actions** choose **Stop**. Once the notebook is stopped, under **Actions** choose **Delete**. If you'd rather keep the notebook around to work with again, then just **Stop** is enough.
    - Endpoint - On the **Endpoints** page in the SageMaker console, click the circle to select the endpoint for the workshop (the endpoint with the name stored in the variable `endpoint_name` from the notebook), then under **Actions** choose **Delete**.
- CloudWatch ([pricing info](https://aws.amazon.com/cloudwatch/pricing/))
    - Logs - The following CloudWatch log groups will have been created for the AWS Lambda functions that you can delete by selecting them and then under **Actions** choosing **Delete log group**.
        - "AWS-SecML-Detection-CloudTrailIngestLambda"
        - "AWS-SecML-Detection-GuardDutyIngestLambda"

