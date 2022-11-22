# AWS-EKS

This repository consists of Terraform templates to bring up AWS EKS cluster with VPC and subnets.

## Usage

- Clone this repo with: `git clone https://github.com/cklewar/aws-eks`
- Enter repository directory with: `cd aws-eks`
- Clone __modules__ repository with: `git clone https://github.com/cklewar/f5-xc-modules`
- Rename __modules__ repository directory name with: `mv f5-xc-modules modules`
- Export AWS `access_key` and `aws_secrect_key` environment variables
- Pick and choose from below examples and add mandatory input data and copy data into file `main.tf.example`
- Rename file __main.tf.example__ to __main.tf__ with: `rename main.tf.example main.tf`
- Apply with: `terraform apply -auto-approve` or destroy with: `terraform destroy -auto-approve`

## AWS ESK with VPC and Subnet

```hcl
variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
  default     = "f5xc"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
  default     = "01"
}

variable "aws_eks_cluster_name" {
  type    = string
  default = "aws-eks-cluster"
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "aws_az_name" {
  type    = string
  default = "us-west-1"
}

variable "aws_az_a" {
  type    = string
  default = "a"
}

variable "aws_az_b" {
  type    = string
  default = "b"
}

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "f5xc_tenant" {
  type    = string
}

variable "owner" {
  type    = string
  default = "c.klewar@f5.com"
}

locals {
  custom_tags = {
    f5xc-tenant  = var.f5xc_tenant
    f5xc-feature = "aws-eks"
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "default"
}

module "aws_eks" {
  source               = "./modules/aws/eks"
  owner                = var.owner
  aws_region           = var.aws_region
  aws_az_name          = var.aws_az_name
  aws_vpc_subnet_a     = "172.16.184.0/24"
  aws_vpc_subnet_b     = "172.16.185.0/24"
  aws_vpc_cidr_block   = "172.16.184.0/21"
  aws_eks_cluster_name = format("%s-%s-%s", var.project_prefix, var.aws_eks_cluster_name, var.project_suffix)
  providers            = {
    aws = aws.default
  }
}

output "eks" {
  value = module.aws_eks.aws_eks
}
```