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

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "owner" {
  type    = string
  default = "c.klewar@f5.com"
}

locals {
  custom_tags = {
    f5xc-tenant  = "playground"
    f5xc-feature = "aws-eks"
  }
}

provider "aws" {
  region = "us-west-2"
  alias  = "default"
}