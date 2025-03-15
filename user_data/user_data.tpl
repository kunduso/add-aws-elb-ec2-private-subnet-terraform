#!/bin/bash
yum update -y
yum install -y httpd.x86_64
# Creates token to authenticate and retrieve instance metadata
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
if [ $? -eq 0 ]; then
    echo "Created token for instance metadata."
else
    echo "Failed to create token."
    exit 1
fi

# Set the AWS region using the token
AWS_REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/placement/region)
if [ $? -eq 0 ]; then
    export AWS_DEFAULT_REGION=$AWS_REGION
    echo "Setting AWS Region to: $AWS_DEFAULT_REGION"
else
    echo "Failed to fetch AWS region."
    exit 1
fi
systemctl start httpd.service
systemctl enable httpd.service
echo "Hello World from $(hostname -f) from the availability zone: $AWS_REGION" > /var/www/html/index.html