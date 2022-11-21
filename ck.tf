provider "aws" {
  region = "us-west-2"
  alias  = "default"
}

module "aws_vpc" {
  source             = "./modules/aws/vpc"
  aws_owner          = var.owner
  aws_region         = var.aws_region
  aws_az_name        = format("%s%s", var.aws_region, var.aws_az)
  aws_vpc_name       = format("%s-%s-vpc-%s", var.project_prefix, var.aws_eks_cluster_name, var.project_suffix)
  aws_vpc_cidr_block = "172.16.40.0/21"
  custom_tags        = {
    f5xc-tenant  = "playground"
    f5xc-feature = "aws-eks"
  }
  providers = {
    aws = aws.default
  }
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