###############################################################################
# TERRAFORM CONFIGURATION 
###############################################################################

terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

###############################################################################
# PROVIDERS 
###############################################################################

provider "aws" {
  profile = "deep-dive"
  region  = var.region
}

###############################################################################
# DATA
###############################################################################

data "aws_availability_zones" "available" {
  state = "available"
}

###############################################################################
# RESOURCES
###############################################################################

# NETWORKING #

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "globo-primary"

  cidr            = var.cidr_block
  azs             = slice(data.aws_availability_zones.available.names, 0, var.subnet_count)
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway      = false
  enable_vpn_gateway      = false
  map_public_ip_on_launch = true

  tags = {
    Environment = "Production"
    Team        = "Network"
  }
}
