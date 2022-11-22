terraform {
  required_version = ">= 1.3.0"
   cloud {
    organization = "cklewar"
    hostname     = "app.terraform.io"

    workspaces {
      name = "aws-subnets-module"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.40.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16.0"
    }

    local = ">= 2.2.3"
    null  = ">= 3.1.1"
  }
}
