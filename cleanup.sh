#!/bin/bash

PROFILE=default
REGION=ca-central-1
STACK_NAME=SEC405

while test $# -gt 0; do
  case "$1" in
    -h|--help)
            echo "Cleans up the workshop CloudFormation stacks by deleting the resources and infrastructure that were created."
            echo " "
            echo "options:"
            echo "-h, --help                	shows this help"
            echo "-p, --profile PROFILE     	specify an AWS CLI profile to use"
            echo "-r, --region REGION       	AWS region to use for the specified profile"
            echo "-s, --stack-name STACK_NAME	CloudFormation stack name to use"
            exit 0
            ;;
    -p|--profile)
            shift
            if test $# -gt 0; then
                export PROFILE=$1
            else
                echo "No profile specified"
                exit 1
            fi
            shift
            ;;
    -r|--region)
            shift
            if test $# -gt 0; then
                export REGION=$1
            else
                echo "No region specified"
                exit 1
            fi
            shift
            ;;
    -s|--stack-name)
            shift
            if test $# -gt 0; then
                export STACK_NAME=$1
            else
                echo "No stack name specified"
                exit 1
            fi
            shift
            ;;
    *)
            break
            ;;
  esac
done

# Delete S3 buckets first, otherwise stack deletion will fail
BUCKETS_TO_DELETE=("TuplesBucket")

for bucket in "${BUCKETS_TO_DELETE[@]}"
do
    bucket_desc=$(aws --profile ${PROFILE} --region ${REGION} cloudformation describe-stack-resource --stack-name ${STACK_NAME} --logical-resource-id ${bucket})

    if [[ -n ${bucket_desc} ]]; then
        actual_bucket_name=$(echo ${bucket_desc} | python -c "import sys, json; print json.load(sys.stdin)['StackResourceDetail']['PhysicalResourceId']")
        
        echo ${acutal_bucket_name}
        
        if [[ -n ${actual_bucket_name} ]]; then
            echo "Deleting the S3 bucket ${bucket} (${actual_bucket_name})"
            aws --profile ${PROFILE} --region ${REGION} s3 rb s3://${actual_bucket_name} --force
        fi
    fi
done

STACKS_TO_DELETE=(
    ${STACK_NAME}
)

for stack in "${STACKS_TO_DELETE[@]}"
do
    echo "Deleting the CloudFormation stack ${stack}"
    
    # Delete the stack
    aws --profile ${PROFILE} --region ${REGION} cloudformation delete-stack --stack-name ${stack}

    # Wait for completion
    # (this command didn't exist in older versions of the AWS CLI, so ignore any errors)
    aws --profile ${PROFILE} --region ${REGION} cloudformation wait stack-delete-complete --stack-name ${stack} || true
done

