# Getting Started with Machine Learning & Data Science for Security
There are three folders in this directory capturing differ

#EDA - Exploratory Data Analysis
This folder contains a documented SQL file used for a few data exploration tasks  
* Create the Athena table
	* Identify the bucket where your CloudTrail logs are located. You'll need the bucket name.
	* Open the file "SEC351-Athena-CT-query-4x4.sql" in a text editor
	* Take note of the initial CREATE TABLE statement.  It's about 50 rows long.
	* Modify the COMMENT and LOCATION statements to reflect your local environment
	* Copy/paste the initial CREATE TABLE statement into your Athena query window.  Execute the query.  

* Create the table PARTIONS
	* Next copy the ALTER TABLE block to a powerful text editor
	* You will need to modify these statements define the relevant partitions for your data
	* _IMPORTANT_ You may need to add or remove lines to account for number of combinations of (acccounts X regions X years X months)  
* Run sample queries
	* The last set of SQL in the file are some sample queries you can use to start to explore your CloudTrail data
	* You will need to modify these queries to fit your data - the accounts, regions, dates, user.arn, and eventname of interest
	* Note the importance of the WHERE clauses that limit the data scans to manageable run times  
 

#modeling-users-api  
Identifying specific users+api pairs with repeating usage and identifying changes
This folder contains a number of artifacts for doing data exploration in Jupyter python notebooks as as building a forecasting model
that is is used to model the behavior of chosen pairs of User+API calls  
* "SEC351-Getting-Started-ML+Security-data exploration.ipynb" - Jupyter notebook for python data exploration
* "SEC351-Time-Series-Model-Build.ipynb" - Jupyter notebooks and SageMaker to build a time series forecasting model
* "simpfile.csv" - trivial data file used to test our SageMaker endpoint when we build a model
* Other files needed for modeling.  Upload these files, as structured, to the Jupyter notebook instance
	* "Dockerfile"
	* "reInvent_Model.ipynb"
	* train - FOLDER: upload the folder to the Jupyter notebook instance and maintain the contents
		* "nginx.conf", "predictor.py", "serve", "train", "wsgi.py"


#reInvent_ipinsights - Finding anomalous IP usage  
In this Jupyter notebook, we use the Amazon SageMaker IP Insights unsupervised anomaly detection algorithm for susicipous IP addresses that uses statistical modeling and neural networks to capture associations between online resources (such as account IDs or hostnames) and IPv4 addresses. It learns vector representations for online resources and IP addresses. If the vector representing an IP address and an online resource are close together, then it is likely (not surprising) for that IP address to access that online resource, even if it has never accessed it before.

We train a model using the <principal ID, IP address> tuples we generated from the CloudTrail log data, and then use the model to perform inference on the same type of tuples generated from GuardDuty findings to determine how unusual it is to see a particular IP address for a given principal involved with a finding.

#batch-scoring-cloudtrail  
A  set of AWS Step Functions to demonstrate a simple deployment scenario.  We'll use a chain of lambda functions to read a day
of CloudTrail logs, parse it, aggregate it, and call the model endpoints to generate anomaly scores.  
* The README.md file in this directory provides detailed instructions for how to define these steps and run them.
