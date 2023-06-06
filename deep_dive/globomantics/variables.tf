###############################################################################
# Variables
###############################################################################

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "ap-south-1"
}

variable "subnet_count" {
  type        = number
  description = "Number of subnets to create"
  default     = 2
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  type        = list(any)
  description = "List of private subnets"
}

variable "public_subnets" {
  type        = list(any)
  description = "List of public subnets"
}
