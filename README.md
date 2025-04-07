[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-white.svg)](https://choosealicense.com/licenses/unlicense/) [![GitHub pull-requests closed](https://img.shields.io/github/issues-pr-closed/kunduso/add-aws-elb-ec2-private-subnet-terraform)](https://github.com/kunduso/add-aws-elb-ec2-private-subnet-terraform/pulls?q=is%3Apr+is%3Aclosed) [![GitHub pull-requests](https://img.shields.io/github/issues-pr/kunduso/add-aws-elb-ec2-private-subnet-terraform)](https://GitHub.com/kunduso/add-aws-elb-ec2-private-subnet-terraform/pull/) 
[![GitHub issues-closed](https://img.shields.io/github/issues-closed/kunduso/add-aws-elb-ec2-private-subnet-terraform)](https://github.com/kunduso/add-aws-elb-ec2-private-subnet-terraform/issues?q=is%3Aissue+is%3Aclosed) [![GitHub issues](https://img.shields.io/github/issues/kunduso/add-aws-elb-ec2-private-subnet-terraform)](https://GitHub.com/kunduso/add-aws-elb-ec2-private-subnet-terraform/issues/) 
[![terraform-infra-provisioning](https://github.com/kunduso/add-aws-elb-ec2-private-subnet-terraform/actions/workflows/terraform.yml/badge.svg)](https://github.com/kunduso/add-aws-elb-ec2-private-subnet-terraform/actions/workflows/terraform.yml) [![checkov-scan](https://github.com/kunduso/add-aws-elb-ec2-private-subnet-terraform/actions/workflows/code-scan.yml/badge.svg)](https://github.com/kunduso/add-aws-elb-ec2-private-subnet-terraform/actions/workflows/code-scan.yml)
## Introduction
This repository contains code to provision various use cases involving Amazon Elastic Load Balancer, Amazon Route53, Amazon Certificate Manager and Amazon EC2 instances using Terraform and GitHub Actions.
## Table of Contents
- [Use Case 1: Create Application Load Balancer and attach to Amazon EC2 instances in a private subnet](#use-case-1-create-application-load-balancer-and-attach-to-amazon-ec2-instances-in-a-private-subnet)
- [Use Case 2: Automate Amazon Route 53 hosted zone, ACM, and Load Balancer provisioning with Terraform and GitHub Actions](#use-case-2-automate-amazon-route-53-hosted-zone-acm-and-load-balancer-provisioning-with-terraform-and-github-actions)
- [Prerequisites](#prerequisites)
- [Supporting References](#supporting-references)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Use Case 1: Create Application Load Balancer and attach to Amazon EC2 instances in a private subnet
**🔔 Attention:** The code for this specific use case is located in the [`ec2-lb`](https://github.com/kunduso/add-aws-elb-ec2-private-subnet-terraform/tree/ec2-lb) branch. Please refer to this branch instead of the default `main` branch. **🔔**
![Image](https://skdevops.files.wordpress.com/2023/07/79-image-1-2.png)
The objective of this use case was to create an application load balancer and attach that to three Amazon EC2 instances hosted in three different availability zones in three separate *private* subnets in a region using **Terraform and GitHub Actions.**
<br />For details please visit - [attach an application load balancer to Amazon EC2 instances in a private subnet.](https://skundunotes.com/2023/07/26/attach-an-application-load-balancer-to-amazon-ec2-instances-in-a-private-subnet/)

## Use Case 2: Automate Amazon Route 53 hosted zone, ACM, and Load Balancer provisioning with Terraform and GitHub Actions
**🔔 Attention:** The code for this specific use case is located in the [`add-acm-r53`](https://github.com/kunduso/add-aws-elb-ec2-private-subnet-terraform/tree/add-acm-r53) branch. Please refer to this branch instead of the default `main` branch. **🔔**
![Image](https://skdevops.files.wordpress.com/2025/03/112-image-0.png)
Building on use case 1, this implementation shows how to:
- Enable secure HTTPS (port 443) access to the static website
- Configure a custom domain name with Amazon Route 53
- Implement SSL/TLS security using AWS Certificate Manager
- Replace the default load balancer DNS with a custom domain

For details please visit - [automate-amazon-route-53-hosted-zone-acm-and-load-balancer-provisioning-with-terraform-and-github-actions.](http://skundunotes.com/2025/03/25/automate-amazon-route-53-hosted-zone-acm-and-load-balancer-provisioning-with-terraform-and-github-actions/)

## Prerequisites
For this code to function without errors, please create an OpenID connect identity provider in Amazon Identity and Access Management that has a trust relationship with this GitHub repository. You can read about it [here](https://skundunotes.com/2023/02/28/securely-integrate-aws-credentials-with-github-actions-using-openid-connect/) to get a detailed explanation with steps.
<br />Store the `ARN` of the `IAM Role` as a GitHub secret which is referred in the [`terraform.yml`](https://github.com/kunduso/add-aws-elb-ec2-private-subnet-terraform/blob/4144f6ea8f2599658a760f382241594aa001b433/.github/workflows/terraform.yml#L31-L36) file.
<br />Since this use case referred to Infracost in this repository, the `INFRACOST_API_KEY` was stored as a repository secret. It is referenced in the `terraform.yml` GitHub actions workflow file.
<br />As part of the Infracost integration, I also created a `INFRACOST_API_KEY` and stored that as a GitHub Actions secret. I also managed the cost estimate process using a GitHub Actions variable `INFRACOST_SCAN_TYPE` where the value is either `hcl_code` or `tf_plan`, depending on the type of scan desired.

## Supporting References
This use cases used [Infracost](https://www.infracost.io/) to generate a cost estimate of building the architecture. If you want to learn more about adding Infracost estimates to your repository, head over to this note - [estimate AWS Cloud resource cost with Infracost, Terraform, and GitHub Actions.](https://skundunotes.com/2023/07/17/estimate-aws-cloud-resource-cost-with-infracost-terraform-and-github-actions/)

The resource provisioning process is automated using GitHub Actions pipeline which is discussed at - [CI-CD with Terraform and GitHub Actions to deploy to AWS.](https://skundunotes.com/2023/03/07/ci-cd-with-terraform-and-github-actions-to-deploy-to-aws/)
## Usage
Ensure that the policy/ies attached to the IAM role whose credentials are being used in this repository has permission to create and manage all the resources that are included in this repository and push the Docker image to Amazon ECR repository.

If you want to check the pipeline logs, click on the **Build Badges** above the image in this ReadMe.

## Contributing
If you find any issues or have suggestions for improvement, feel free to open an issue or submit a pull request. Contributions are always welcome!

## License
This code is released under the Unlicense License. See [LICENSE](LICENSE).