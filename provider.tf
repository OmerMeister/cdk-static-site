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
    archive = {
      source  = "hashicorp/archive"
      version = ">=2.4.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}