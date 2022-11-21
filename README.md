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

variable "aws_az" {
  type    = string
  default = "a"
}

variable "owner" {
  type    = string
  default = "c.klewar@f5.com"
}

module "aws_vpc" {
  source             = "./modules/aws/vpc"
  aws_owner          = var.owner
  aws_region         = var.aws_region
  aws_az_name        = format("%s%s", var.aws_region, var.aws_az)
  aws_vpc_name       = format("%s-%s-vpc-%s", var.project_prefix, var.aws_eks_cluster_name, var.project_suffix)
  aws_vpc_cidr_block = "172.16.192.0/21"
  custom_tags        = {
    Name = format("%s-%s-vpc-%s", var.project_prefix, var.aws_eks_cluster_name, var.project_suffix)
  }
}

provider "aws" {
  region = "us-west-2"
  alias  = "default"
}

module "aws_subnet" {
  source          = "./modules/aws/subnet"
  aws_vpc_id      = module.aws_vpc.aws_vpc["id"]
  aws_vpc_subnets = [
    {
      name                    = format("%s-aws-eks-subnet-a-%s", var.project_prefix, var.project_suffix)
      owner                   = var.owner
      map_public_ip_on_launch = true
      cidr_block              = "172.16.40.0/24"
      availability_zone       = format("%s%s", var.aws_region, var.aws_az)
      custom_tags             = {
        f5xc-tenant  = "playground"
        f5xc-feature = "aws-eks"
      }
    },
    {
      name                    = format("%s-aws-eks-subnet-b-%s", var.project_prefix, var.project_suffix)
      owner                   = var.owner
      map_public_ip_on_launch = true
      cidr_block              = "172.16.41.0/24"
      availability_zone       = format("%s%s", var.aws_region, var.aws_az)
      custom_tags             = {
        f5xc-tenant  = "playground"
        f5xc-feature = "aws-eks"
      }
    }
  ]
  providers = {
    aws = aws.default
  }
}

output "aws_subnets" {
  value = {
    format("%s-aws-subnet-a-%s", var.project_prefix, var.project_suffix) = {
      "id"     = module.aws_subnet.aws_subnets[format("%s-aws-eks-subnet-a-%s", var.project_prefix, var.project_suffix)]["id"]
      "vpc_id" = module.aws_subnet.aws_subnets[format("%s-aws-eks-subnet-a-%s", var.project_prefix, var.project_suffix)]["vpc_id"]
    }
    format("%s-aws-subnet-b-%s", var.project_prefix, var.project_suffix) = {
      "id"     = module.aws_subnet.aws_subnets[format("%s-aws-eks-subnet-b-%s", var.project_prefix, var.project_suffix)]["id"]
      "vpc_id" = module.aws_subnet.aws_subnets[format("%s-aws-eks-subnet-b-%s", var.project_prefix, var.project_suffix)]["vpc_id"]
    }
  }
}

module "aws_eks" {
  source                      = "./modules/aws/eks"
  iam_owner                   = var.owner
  aws_region                  = "us-west-2"
  aws_vpc_id                  = module.aws_vpc.aws_vpc["id"]
  aws_access_key              = var.aws_access_key_id
  aws_secret_key              = var.aws_secret_access_key
  aws_subnet_ids              = [for s in module.aws_subnet.aws_subnets : s["id"]]
  aws_eks_cluster_name        = var.aws_eks_cluster_name
  aws_vpc_zone_identifier     = [for s in module.aws_subnet.aws_subnets : s["id"]]
  aws_endpoint_public_access  = true
  aws_endpoint_private_access = true
  providers                   = {
    aws = aws.default
  }
}

output "kubeconfig" {
  value = module.aws_eks.aws_eks["kubeconfig"]
}

output "config_map_aws_auth" {
  value = module.aws_eks.aws_eks["config_map_aws_auth"]
}
```