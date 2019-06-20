# Using ML with Amazon SageMaker & GuardDuty to identify anomalous traffic

Welcome! This guide provides instructions and pointers to the resources used for the workshop.

* **Level**: Intermediate
* **Duration**: 2 hours
* **CAF Components**: Detective, Responsive
* **Prerequisites**: Active email address, Modern, graphical web browser - sorry Lynx users :)

This documents helps you get started with the Jam Platform and then walks your through the following exercises:

1. Enabling Amazon GuardDuty and exploring GuarDuty findings
2. Using AWS Lambda to transform data so it is suitable for model training and inference
3. IP-based anomaly detection in SageMaker


## Initial setup

### Prerequisites
- You do not need an AWS account for this workshop.  You will be using the AWS Jam Platform to access a temporary AWS account to run the lab.
- Modern, graphical web browser - sorry Lynx users :)

**Before getting started, you will need to setup an account on the AWS Jam Platform.**
- If you do not already have a Jam account, you will need an active email address to register
- Go to https://jam.awsevents.com/ and enroll in an account
- Your Workshop Facilitator will give you the Secret Key necessary to access today's Jam Event

### Welcome the Jam Platform
For this workshop, there will be only one "Jam Challenge" available to you in the Jam Console.
- Please click on the challenge **Who was that IP address I saw you with last night?**
- You will see a brief description of the lab.
- Click on **View Details**, and you will a longer summary of the lab.  Go ahead and read this, and then...
- Click on the blue **Start Challenge** button.  You will see a pop-up message that says, _This challenge is still deploying. Please check back soon._

It will take a few minutes for the Jam Platform to create and provision your temporary account for the lab.  In the meantime, your facilitators will take some time to walk through some key concepts in the lab.

When the Workshop Facilitator tells you to begin, you can refresh this page in the web browser.  You should now see an option near the top to **Open AWS Console** (blue button).  If you click this button, a new browser tab should open in your new, temporary AWS account.


## Exercise 1: Examining GuardDuty findings

In this exercise, you will generate and examine sample GuardDuty findings to understand what information they contain, and then also look at several "real" GuardDuty findings that were generated from actual AWS account activity.

The goal of this exercise is to familiarize with the kinds of information contained in GuardDuty findings, and the structure of the findings themselves.

### 1.1 Generate sample findings

1. From the **Services** dropdown in the top left, browse to the GuardDuty console (just type "GuardDuty" into the search box).
2. Verify that you are in the **US West (Oregon)** region via the region dropdown in the top right; if not, please switch to that region.
3. GuardDuty should not yet be enabled in this account.  Click the **Get Started** button in the middle of the screen.
3. Next, click the button labelled **Enable GuardDuty** to turn it on with a single click.
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

## Exercise 2: Using AWS Lambda to transform data so it is suitable for model training and inference

In this exercise, you will use AWS to transform our data.  In real-world ML/Data Science projects, the data exploration and transofrmation is a critical part of the solution, and often requires a significant time investment.  For this lab, we're going to simplify things for you, and just give you a flavor of the data preparation process.  You will use two Lambda functions to prepare the input data for the ML algorithm from the source CloudTrail and GuardDuty log data. You will generate training data consisting of `<principal ID, IP address>` tuples from the CloudTrail logs and then you will call the trained model to make inferences to score the GuardDuty findings from Exercise 1 by using a similar set of tuples generated from the findings. The GuardDuty findings are based on the same set of account activity as the CloudTrail logs.

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
2. A function `get_tuples` has been provided to take GuardDuty findings as input and return `<principal ID, IP address>` tuples for each finding. A call to this function has already been set up in the `handler` function (search for the string "TODO"), but the line is commented out. Uncomment it.
3. Click the **Save** button at the top to save your function changes.
4. Click the **Test** button to run the function again. This time it write the tuples to the S3 bucket where they can be loaded into the IP Insights algorithm for scoring.

In the S3 console, if you go into the bucket whose name starts with "aws-secml-detection-tuplesbucket", you should now see a file "infer/guardduty_tuples.csv" inside that contains some `<principal ID, IP address>` tuples.


## Exercise 3: IP-based anomaly detection in SageMaker
Now, it's time to build a machine learning model with SageMaker. The IP Insights SageMaker machine learning algorithm will use the CloudTrail data we've prepared to learn what "normal" IP address usage looks like, and then we'll see how the IP addresses coming from GuardDuty appear to that model - how anomalous they look.


### 3.1 Set up the SageMaker notebook
To use the IP Insights algorithm, you will work from a Jupyter notebook, which is an interactive coding environment that lets you mix notes and documentation with code blocks that can be "run" in a stepwise fashion throughout the notebook and share the same interpreter.

1. Browse to the Amazon SageMaker console and click on the button called **Create notebook instance**.
2. You will have to fill in a Notebook Instance Name in the top box: use "AWS-SecML-Detection"
3. For Notebook instance type, we recommend selecting ml.t2.medium.
4. Leave the Elastic Inference box set to "None"

5. In **Permissions and Encryption**, for IAM role, choose "Enter a Customer IAM role arn" in the dropdown.
6. Copy/paste this string into the arn parameter  
        **arn:aws:iam::[ACCTNUMBER]:role/MLSecWorkshopSageMakerRole**
7. You'll need to paste your account number into this strong before proceeding.  The Jam platform makes this easy...
8. Go back to the Jam console and on the left-hand side, click the **AWS Account** option
9. Copy the 12-digit account number
10. Paste that number into the ARN back in the SageMaker notebook console in place of **[ACCTNUMBER]**.  Your final string should look something like this  
   arn:aws:iam::123456789012:role/MLSecWorkshopSageMakerRole
6. All other notebook options can be left at defaults. Click **Create notebook instance**.
7. Once the notebook is running, click **Open Jupyter** to open the notebook.
8. Download the sample notebook file for the workshop where we will be working with the IP Insights algorithm: <https://s3.us-west-2.amazonaws.com/aws-workshop-security-ml-threat-detection/mlsec-workshop-ipinsights.ipynb>
9. Once you download the notebook file, click the **Upload** button on the upper right hand side in Jupyter to upload it to your running notebook instance.

### 3.2 Training and scoring with the IP Insights algorithm

Click on the notebook and work through it step by step to learn how to train the model using the tuples from the CloudTrail logs and then make inferences by scoring the tuples from the GuardDuty findings. We recommend using the "Run" command to walk through each code block one by one rather than doing "Run All".

IP Insights is an unsupervised learning algorithm for detecting anomalous behavior and usage patterns of IP addresses, that helps users identifying fraudulent behavior using IP addresses, describe the Amazon SageMaker IP Insights algorithm, demonstrate how you can use it in a real-world application, and share some of our results using it internally.

For more information about the IP Insights algorithm, please read the following AWS blog post:

<https://aws.amazon.com/blogs/machine-learning/detect-suspicious-ip-addresses-with-the-amazon-sagemaker-ip-insights-algorithm/>

You can also view the IP Insights documentation here:

<https://docs.aws.amazon.com/sagemaker/latest/dg/ip-insights.html>

**2.4.1 (BONUS) IP Insights algorithm tutorial**

If you would like to experiment with the IP Insights algorithm using a much larger dataset, you can choose the **SageMaker Examples** tab in Jupyter to see a list of all the Amazon SageMaker examples. Expand the **Introduction to Amazon Algorithms** section, look for a notebook called **ipinsights-tutorial.ipynb**, then click its **Use** button and **Create copy** in the dialog to create a copy of it, then work through it step by step.

##  How can I reuse the artifacts in this lab?

All of the code and artifacts used in this lab - including these instructions, but not including the Jam Platform - are available in a public GitHub [repository](https://github.com/aws-samples/aws-ml-detection-workshop/).  There you will find the following files:

- aws_lambda/
    - cloudtrail_ingest.zip - Lambda zip bundle for workshop CloudTrail log ingest
    - guardduty_ingest.zip - Lambda zip bundle for workshop GuardDuty finding ingest
- templates/
    - cloudformation.yaml - The CloudFormation template to deploy the stack of resources for the workshop
- mlsec-participant-policy.json - The IAM policy specifying the permissions needed for the lab user
- workshop-ipinsights.ipynb - Jupyter notebook for the workshop to load into SageMaker
