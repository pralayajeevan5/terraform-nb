# Bucket name
variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to store the Terraform state file"
}

# ELB service account ARN
variable "elb_service_account_arn" {
  type        = string
  description = "ARN of the IAM role to be assumed by the ELB service account"
}

# Common tags
variable "common_tags" {
  type    = map(string)
  default = {}
}
