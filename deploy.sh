#!/bin/bash -eu

ACCOUNT_A_PROFILE=
ACCOUNT_B_PROFILE=

HOSTED_ZONE_ID=
DOMAIN_NAME=
BucketName=
BucketRegion=

aws --profile ${ACCOUNT_A_PROFILE} cloudformation deploy --stack-name s3-bucket-origin \
    --template-file ./templates/1-account1-s3-bucket.yml \
    --parameter-overrides BucketName=${BucketName}

aws --profile ${ACCOUNT_B_PROFILE} --region us-east-1 cloudformation deploy --stack-name cloudfront-with-ssl \
    --template-file ./templates/2-account2-cloudfront.yml \
    --parameter-overrides \
    HostedZoneId=${HOSTED_ZONE_ID} \
    DomainName=${DOMAIN_NAME} \
    BucketName=${BucketName} \
    BucketRegion=${BucketRegion} \
    BucketAccountId=$(aws sts --profile ${ACCOUNT_A_PROFILE} get-caller-identity --query Account --output text)

cloudfront_distribution_id=$(aws --profile ${ACCOUNT_B_PROFILE} --region us-east-1 cloudformation describe-stacks --stack-name cloudfront-with-ssl --query "Stacks[0].Outputs[?OutputKey=='CloudFrontDistributionId'].OutputValue" --output text)

aws --profile ${ACCOUNT_A_PROFILE} cloudformation deploy --stack-name s3-bucket-policy \
    --template-file ./templates/3-s3-bucket-policy.yml \
    --parameter-overrides \
    BucketName=${BucketName} \
    DistributionId=${cloudfront_distribution_id} \
    TargetAccountId=$(aws sts --profile ${ACCOUNT_B_PROFILE} get-caller-identity --query Account --output text)
