
[![terraform-infra-provisioning](https://github.com/kunduso/add-aws-elb-ec2-private-subnet-terraform/actions/workflows/terraform.yml/badge.svg)](https://github.com/kunduso/add-aws-elb-ec2-private-subnet-terraform/actions/workflows/terraform.yml) [![checkov-scan](https://github.com/kunduso/add-aws-elb-ec2-private-subnet-terraform/actions/workflows/code-scan.yml/badge.svg)](https://github.com/kunduso/add-aws-elb-ec2-private-subnet-terraform/actions/workflows/code-scan.yml) [![infracost](https://img.shields.io/endpoint?url=https://dashboard.api.infracost.io/shields/json/06af6e89-01e0-4bb5-bf85-ea19a0d3327a/repos/4af32dcb-55e6-46d7-a287-9fd4d1fc4f39/branch/1e692b50-7249-40e4-a08f-2d15faa7ccfb)](https://dashboard.infracost.io/org/skundudev/repos/4af32dcb-55e6-46d7-a287-9fd4d1fc4f39?tab=settings)
![Image](https://skdevops.files.wordpress.com/2023/07/79-image-1-1.png)
## Motivation
My objectives was to create an application load balancer and attach that to three Amazon EC2 instances hosted in three different availability zones in three separate *private* subnets in a region using **Terraform and GitHub Actions.**

<br />I discussed the concept in detail in my notes at -[attach an application load balancer to Amazon EC2 instances in a private subnet.](https://skundunotes.com/2023/07/26/attach-an-application-load-balancer-to-amazon-ec2-instances-in-a-private-subnet/)
<br />I also used [Infracost](https://www.infracost.io/) to generate a cost estimate of building the architecture. Checkout the cool *monthly cost badge* at the top of this file. If you want to learn more about adding Infracost estimates to your repository, head over to this note -[estimate AWS Cloud resource cost with Infracost, Terraform, and GitHub Actions.](https://skundunotes.com/2023/07/17/estimate-aws-cloud-resource-cost-with-infracost-terraform-and-github-actions/)
<br />Lastly, I also automated the process of provisioning the resources using GitHub Actions pipeline and I discussed that in detail at -[CI-CD with Terraform and GitHub Actions to deploy to AWS.](https://skundunotes.com/2023/03/07/ci-cd-with-terraform-and-github-actions-to-deploy-to-aws/)

<br />*Note: I did not include the concepts of creating the EC2 instances, or installing a certificate, or route53 in this note.*

## Prerequisites
For this code to function without errors, I created an OpenID connect identity provider in Amazon Identity and Access Management that has a trust relationship with this GitHub repository. You can read about it [here](https://skundunotes.com/2023/02/28/securely-integrate-aws-credentials-with-github-actions-using-openid-connect/) to get a detailed explanation with steps.
<br />I stored the `ARN` of the `IAM Role` as a GitHub secret which is referred in the [`terraform.yml`](https://github.com/kunduso/add-aws-elb-ec2-private-subnet-terraform/blob/4144f6ea8f2599658a760f382241594aa001b433/.github/workflows/terraform.yml#L31-L36) file.
<br />Since I used Infracost in this repository, I stored the `INFRACOST_API_KEY` as a repository secret. It is referenced in the `terraform.yml` GitHub actions workflow file.
<br />As part of the Infracost integration, I also created a `INFRACOST_API_KEY` and stored that as a GitHub Actions secret. I also managed the cost estimate process using a GitHub Actions variable `INFRACOST_SCAN_TYPE` where the value is either `hcl_code` or `tf_plan`, depending on the type of scan desired.
## Usage
Ensure that the policy attached to the IAM role whose credentials are being used in this configuration has permission to create and manage all the resources that are included in this repository.
<br />
<br />Review the code including the [`terraform.yml`](./.github/workflows/terraform.yml) to understand the steps in the GitHub Actions pipeline. Also review the `terraform` code to understand all the concepts associated with creating an AWS VPC, subnets, internet gateway, route table, and route table association.
<br />If you want to check the pipeline logs, click on the **Build Badge** (terrform-infra-provisioning) above the image in this ReadMe.