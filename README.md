# Cross Account CloudFront S3

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Cross Account CloudFront S3](#cross-account-cloudfront-s3)
  - [Prerequisites](#prerequisites)
    - [AWS Configure](#aws-configure)
  - [Usage](#usage)
  - [How it works](#how-it-works)
  - [Cleanup](#cleanup)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Infrastructure as Code (IaC) for a CloudFront distribution that serves content
from a private S3 bucket in a different AWS account.

## Prerequisites

- [AWS CLI](https://aws.amazon.com/cli/)
- Two AWS accounts [configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
with **different profile names**.
- A [public hosted zone in AWS Route53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/AboutHZWorkingWith.html)
in the account where the CloudFront distribution will be created.

### AWS Configure

Upon running `aws configure --profile account1` and
`aws configure --profile account2`, you will have a file in
`~/.aws/credentials` that looks like this:

```ini
[account1]
aws_access_key_id = <your access key id>
aws_secret_access_key = <your secret access key>

[account2]
aws_access_key_id = <your access key id>
aws_secret_access_key = <your secret access key>
```

Also, the config file `~/.aws/config` will look like this:

```ini
[profile account1]
region = us-east-1

[profile account2]
region = us-east-1
```

You will then pass `account1` and `account2` as `ACCOUNT_A_PROFILE` &
`ACCOUNT_B_PROFILE` variables in the `deploy.sh` and `cleanup.sh` scripts.

## Usage

Fill in the required values in the [deploy.sh](deploy.sh) script and run it.

## How it works

1. First, a new S3 bucket will be created in the first account, optionally with
encryption enabled. This bucket will be private and only accessible by the
account owner and the CloudFront distribution in the second account.
2. The bucket name will be passed to the second step, which will create a new
CloudFront distribution that will serve the content from the S3 bucket hosted
in the first account. The access to the private bucket is made possible by
two pieces:
    - The [Origin Access Control](https://aws.amazon.com/blogs/networking-and-content-delivery/amazon-cloudfront-introduces-origin-access-control-oac/)
used by the CloudFront distribution.
    - The bucket policy applied on the S3 bucket in the third step below.
3. The bucket policy will be created in the first account, allowing the
CloudFront distribution to access the S3 bucket. The policy will be created
using the CloudFront distribution's Origin Access Control (OAC) ID as the
principal. This will allow the CloudFront distribution to access the S3 bucket
without needing to expose the bucket publicly i.e. ensuring that the objects
are not accessible through the S3 bucket URL e.g. static website.

## Cleanup

Fill in the required values in the [cleanup.sh](cleanup.sh) script and run it.
