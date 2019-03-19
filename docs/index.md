# Scalable, Automated Anomaly Detection with Amazon GuardDuty and SageMaker

In this README you will find instructions and pointers to the resources used for the workshop. This workshop contains the following exercises:

1. Examining GuardDuty findings
2. IP-based anomaly detection in SageMaker

After the setup steps below, there are instructions provided for all of the hands-on exercises, instructions of how to delete the CloudFormation stack, and following that a full walkthrough guide on how to complete the exercises.

* **Level**: Intermediate
* **Duration**: 2 hours
* **CSF Functions**: Detect, Respond
* **CAF Components**: Detective, Responsive
* **<a href="https://awssecworkshops.com/getting-started/" target="_blank">Prerequisites</a href>**: AWS Account, Admin IAM User

## What's in here?

This repository contains the following files that will be used for this workshop:

- aws_lambda/
  - cloudtrail_ingest.zip - Lambda zip bundle for workshop CloudTrail log ingest
  - guardduty_ingest.zip - Lambda zip bundle for workshop GuardDuty finding ingest
- cleanup.sh - Shell script to delete the workshop CloudFormation stack at the end
- workshop-ipinsights.ipynb - Jupyter notebook for the workshop to load into SageMaker
- templates/
  - cloudformation.yaml - The CloudFormation template to deploy the stack of resources for the workshop

## Initial setup

### Prerequisites

Before getting started, you will need the following:

- AWS account
  - **Please note** if your AWS account is brand new (<24 hours old), you might encounter errors during the workshop when creating some resources.
- Modern, graphical web browser - sorry Lynx users :)
- IAM user with administrator access to the account

### Deploying the CloudFormation template

The CloudFormation template creates the following:

- 2 Lambda functions
  - CloudTrail log file ingester
  - GuardDuty finding ingester
- IAM role used by the Lambda functions
- S3 bucket used for outputting (principal ID, IP address) tuples

First, log in to your AWS account using the IAM user with administrator access.

To easily deploy the CloudFormation stack, please browse to the following stack launch URL:

https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/new?stackName=AWS-SecML-Detection&templateURL=https://s3.us-west-2.amazonaws.com/aws-workshop-security-ml-threat-detection/cloudformation.yaml

The stack launch URL uses a copy of the CloudFormation template from *templates/cloudformation.yaml* that is contained in an S3 bucket and is the same as the one in this code repository. It creates a CloudFormation stack in the US West (Oregon) region also known as us-west-2, with the name "AWS-SecML-Detection".

1. On the **Select Template** page, note that the template location where it says "Specify an Amazon S3 template URL" is pre-populated with the S3 URL to the template. Click **Next**.
2. On the **Specify Details** page, click **Next**.
3. On the **Options** screen, click **Next**.
4. On the Review page, check the box for “I acknowledge that AWS CloudFormation might create IAM resources” since the template creates an IAM role.
5. Click **Create** to deploy the stack. While the CloudFormation stack is being created, you can view its status in the AWS CloudFormation console. You should see a green **Status** of **CREATE_COMPLETE** in just a few minutes.

While waiting for the CloudFormation stack to complete, you may proceed with Exercise 1.

## Exercise 1: Examining GuardDuty findings

In this exercise, you will generate and examine sample GuardDuty findings to understand what information they contain, and then also look at several "real" GuardDuty findings that were generated from actual AWS account activity.

The goal of this exercise is to familiarize with the kinds of information contained in GuardDuty findings, and the structure of the findings themselves.

### 1.1 Generate sample findings

1. From the **Services** dropdown in the top left, browse to the GuardDuty console (just type "GuardDuty" into the search box).
2. Verify that you are in the **US West (Oregon)** region via the region dropdown in the top right; if not, please switch to that region.
3. If GuardDuty is not yet enabled, click the button labelled **Enable GuardDuty** to turn it on with a single click.
4. In the left menu click **Settings**, scroll down to the section titled "Sample Findings", then click on the button labelled **Generate sample findings** to generate a sample GuardDuty finding for every finding type.
5. Click on **Findings** in the left menu and examine some of the sample findings shown in the GuardDuty console. What kinds of information do you see?
6. Examine some of the findings with a threat purpose of "UnauthorizedAccess".

### 1.2 Examining real findings

The "real" GuardDuty findings that were generated for this workshop are contained in an S3 bucket as JSON. Rather than look at them in S3, we're going to run the AWS Lambda ingester function for the GuardDuty findings that will read in the findings from the S3 bucket and print them out.

1. Browse to the AWS Lambda console and click on the Lambda function whose name starts with "AWS-SecML-Detection-GuardDutyIngestLambda".
2. Scroll down to view the code for the Lambda function in the inline, browser-based editor. Skim through the code to familiarize with what it does.
3. Click the **Test** button to run the function. You will need to create a test event to do this, but the event actually does not matter in this case, so just use the "Hello World" event template, give it the name "Workshop", then click **Create**. You then need to click the **Test** button once more.
4. Examine the output, where you'll see the JSON for each GuardDuty finding being printed by the function `print_full_finding`. Look over the findings to see what information they contain.
5. A function called `print_short_finding` is also defined to print out a shortened, one-line version of each GuardDuty finding. Replace the call to the function `print_full_finding` with `print_short_finding` (hint: Search for "TODO" around line 135. You will see multiple TODOs in the file, but only the first one applies here.).
6. Click the **Save** button at the top of the screen to save your changes to the function, then click **Test** to run it again. Observe the new output, where you will now see a summarized version of each finding being printed.

## Exercise 2: IP-based anomaly detection in SageMaker

In this exercise, you will use the IP Insights SageMaker machine learning algorithm to learn how unusual GuardDuty findings are for given principals (i.e., IAM users or roles) based on IP address.

First, you will use two Lambda functions to prepare the input data for the ML algorithm from the source CloudTrail and GuardDuty log data. You will generate training data consisting of `<principal ID, IP address>` tuples from the CloudTrail logs and then you will call the trained model to make inferences to score the GuardDuty findings from Exercise 1 by using a similar set of tuples generated from the findings. The GuardDuty findings are based on the same set of account activity as the CloudTrail logs.

### 2.1 Generate training data using CloudTrail logs

In order to use the IP Insights model, we need some training data. We will train the model by passing `<principal ID, IP address>` tuples extracted from CloudTrail logs.
    
An AWS Lambda function has been created to do this, but you'll need to make a small change to the function and then run it to generate the tuples.

1. Browse to the AWS Lambda console and click on the Lambda function whose name starts with "AWS-SecML-Detection-CloudTrailIngestLambda".
2. Scroll down to view the code for the Lambda function in the inline, browser-based editor. Skim through the code to familiarize with what it does.
3. Click the **Test** button to run the function. You will need to create a test event to do this, but the event actually does not matter in this case, so just use the "Hello World" event template and give it the name "Workshop", then click **Create**. You then need to click the **Test** button once more.
4. Look at the output of the function, where you'll see a short version of each CloudTrail record returned by the function `print_short_record` being printed.
5. A function `get_tuple` has been provided to take a CloudTrail record as input and return a `<principal ID, IP address>` tuple for each record. A call to this function has already been set up in the `handler` function, but the lines are commented out (hint: search for the string "TODO"). Uncomment both lines.
6. Click the **Save** button at the top to save your function changes.
7. Click the **Test** button to run the function again. This time it will write the tuples to the S3 bucket where they can be loaded into the IP Insights algorithm for training the model.

In the S3 console, if you go into the bucket whose name starts with "aws-secml-detection-tuplesbucket", you should now see a file "train/cloudtrail_tuples.csv" inside that contains some `<principal ID, IP address>` tuples.

### 2.2 Generate scoring data using GuardDuty findings

To make use of the trained model, we will pass `<principal ID, IP address>` tuples extracted from the GuardDuty findings to it for scoring (i.e., inference). The activity contained in these GuardDuty findings directly corresponds to the activity contained in the CloudTrail logs.
    
An AWS Lambda function has been created to do this, but you'll need to make a small change to the function and then run it to generate the tuples.

1. Browse to the AWS Lambda console and click on the Lambda function whose name starts with "AWS-SecML-Detection-GuardDutyIngestLambda".
2. A function `get_tuples` has been provided to take GuardDuty findings as input and return `<principal ID, IP address>` tuples for each finding. A call to this function has already been set up in the `handler` function (search for the string "TODO"), but the line is is commented out. Uncomment it.
3. Click the **Save** button at the top to save your function changes.
4. Click the **Test** button to run the function again. This time it write the tuples to the S3 bucket where they can be loaded into the IP Insights algorithm for scoring.

In the S3 console, if you go into the bucket whose name starts with "aws-secml-detection-tuplesbucket", you should now see a file "infer/guardduty_tuples.csv" inside that contains some `<principal ID, IP address>` tuples.

### 2.3 Set up the SageMaker notebook

To use the IP Insights algorithm, you will work from a Jupyter notebook, which is an interactive coding environment that lets you mix notes and documentation with code blocks that can be "run" in a stepwise fashion throughout the notebook and share the same interpreter.

1. First, go to the S3 console and look for the bucket whose name starts with "aws-secml-detection-tuplesbucket" (e.g., aws-secml-detection-tuplesbucket-1fnqifqbmsfxy). Copy the name of this bucket; you will need it in a moment.
2. Browse to the Amazon SageMaker console and click on the button called **Create notebook instance**.
3. On the next screen, give the notebook a name "AWS-SecML-Detection".
4. For Notebook instance type, we recommend selecting ml.t2.medium.
5. For IAM role, choose "Create a new role" in the dropdown. On the next dialog, ensure "S3 buckets you specify" is selected, in the text field for "Specific S3 buckets" paste the name of the S3 bucket from step 1, and click **Create role**.
6. All other notebook options can be left at defaults. Click **Create notebook instance**.
7. Once the notebook is running, click **Open Jupyter** to open the notebook.
8. Download the sample notebook file for the workshop where we will be working with the IP Insights algorithm: https://s3.us-west-2.amazonaws.com/aws-workshop-security-ml-threat-detection/workshop-ipinsights.ipynb
9. Once you download the notebook file, click the **Upload** button on the upper right hand side in Jupyter to upload it to your running notebook instance.

### 2.4 Training and scoring with the IP Insights algorithm

Click on the notebook and work through it step by step to learn how to train the model using the tuples from the CloudTrail logs and then make inferences by scoring the tuples from the GuardDuty findings. We recommend using the "Run" command to walk through each code block one by one rather than doing "Run All".

IP Insights is an unsupervised learning algorithm for detecting anomalous behavior and usage patterns of IP addresses, that helps users identifying fraudulent behavior using IP addresses, describe the Amazon SageMaker IP Insights algorithm, demonstrate how you can use it in a real-world application, and share some of our results using it internally.

For more information about the IP Insights algorithm, please read the following AWS blog post:

https://aws.amazon.com/blogs/machine-learning/detect-suspicious-ip-addresses-with-the-amazon-sagemaker-ip-insights-algorithm/

You can also view the IP Insights documentation here:

https://docs.aws.amazon.com/sagemaker/latest/dg/ip-insights.html

**2.4.1 (BONUS) IP Insights algorithm tutorial**

If you would like to experiment with the IP Insights algorithm using a much larger dataset, you can choose the **SageMaker Examples** tab in Jupyter to see a list of all the Amazon SageMaker examples. Expand the **Introduction to Amazon Algorithms** section, look for a notebook called **ipinsights-tutorial.ipynb**, then click its **Use** button and **Create copy** in the dialog to create a copy of it, then work through it step by step.

## Cleaning up

In order to prevent charges to your account from the resources created during this workshop, we recommend cleaning up the infrastructure that was created by deleting the CloudFormation stack. You can leave things running though if you want to do more with the workshop; the following cleanup steps can be performed at any time.

We've created a Bash script to delete the CloudFormation stack, which will remove the Lambda functions, IAM role, and S3 bucket. We use a script because the S3 bucket has The script, `cleanup.sh`, is provided in this repository.

[Click here](https://github.com/aws-samples/aws-ml-detection-workshop) to go to the repository, then download the script `cleanup.sh` and run it as follows:

```
chmod +x cleanup.sh
./cleanup.sh
```

If you are using a different AWS CLI profile than the default, you can specify it with the `-p PROFILE` parameter to the script, like `cleanup.sh -p foo`.

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
