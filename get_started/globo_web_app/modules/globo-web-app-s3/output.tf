# Bucket object
output "bucket" {
  value = aws_s3_bucket.bucket
}

# Instance profile object
output "instance_profile" {
  value = aws_iam_instance_profile.instance_profile
}
