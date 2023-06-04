## aws_s3_bucket
resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = var.common_tags
}

## aws_s3_bucket_policy
resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "arn:aws:s3:::${var.bucket_name}/alb-logs/*"
        Principal = {
          AWS = var.elb_service_account_arn
        }
      }
    ]
  })
}

## aws_iam_role
# This role is used by the EC2 instance to access the S3 bucket
resource "aws_iam_role" "instance" {
  name = "${var.bucket_name}-instance"
  tags = var.common_tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com"]
        }
      }
    ]
  })
}

## aws_iam_role_policy
resource "aws_iam_role_policy" "instance" {
  name = "${var.bucket_name}-instance"
  role = aws_iam_role.instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:GetObject", "s3:ListBucket"]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.bucket.arn}",
          "${aws_s3_bucket.bucket.arn}/*"
        ]
      }
    ]
  })
}

## aws_iam_instance_profile
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.bucket_name}-nginx"
  role = aws_iam_role.instance.id
  tags = var.common_tags
}
