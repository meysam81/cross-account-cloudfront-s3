#!/bin/bash -eu

ACCOUNT_A_PROFILE=
ACCOUNT_B_PROFILE=

aws --profile ${ACCOUNT_A_PROFILE} cloudformation delete-stack --stack-name s3-bucket-origin

aws --profile ${ACCOUNT_B_PROFILE} --region us-east-1 cloudformation delete-stack --stack-name cloudfront-with-ssl

aws --profile ${ACCOUNT_A_PROFILE} cloudformation delete-stack --stack-name s3-bucket-policy
