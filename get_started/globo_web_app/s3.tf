## aws_s3_bucket
resource "aws_s3_bucket" "weblog" {
  bucket        = local.s3_bucket_name
  force_destroy = true

  tags = local.common_tags
}

## aws_s3_bucket_policy
resource "aws_s3_bucket_policy" "weblog" {
  bucket = aws_s3_bucket.weblog.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*"
        Principal = {
          AWS = data.aws_elb_service_account.root.arn
        }
      }
    ]
  })
}


## aws_s3_bucket_object
resource "aws_s3_object" "weblog_bucket_objects" {
  for_each = {
    "website" = "website/index.html",
    "logo"    = "website/Globo_logo_Vert.png"
  }

  bucket = aws_s3_bucket.weblog.id
  key    = each.value
  source = each.value

  tags = local.common_tags
}


## aws_iam_role
# This role is used by the EC2 instance to access the S3 bucket
resource "aws_iam_role" "instance" {
  name = "${local.name_prefix}-weblog-instance"
  tags = local.common_tags
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
  name = "${local.name_prefix}-weblog-instance"
  role = aws_iam_role.instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.weblog.arn}/*"
      }
    ]
  })
}

## aws_iam_instance_profile
resource "aws_iam_instance_profile" "nginx" {
  name = "${local.name_prefix}-nginx"
  role = aws_iam_role.instance.id
  tags = local.common_tags
}
