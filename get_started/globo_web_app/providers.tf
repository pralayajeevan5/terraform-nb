#################################################################
# TERRAFORM CONFIGURATION
#################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    # We are going to use random provider to generate random string
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

#################################################################
# PROVIDERS
#################################################################

provider "aws" {
  region = var.aws_region
}
