# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# The following variable is used to configure the provider's authentication
# token. You don't need to provide a token on the command line to apply changes,
# though: using the remote backend, Terraform will execute remotely in Terraform
# Cloud where your token is already securely stored in your workspace!

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.18"
    }
    template = {
      source  = "hashicorp/template"
      version = ">=2.2.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

provider "github" {
  token = var.WEBCONTENT_REPO_ACCESS_KEY # Replace with your GitHub access token
}