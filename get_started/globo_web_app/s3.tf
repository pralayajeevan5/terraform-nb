module "s3" {
  source = "./modules/globo-web-app-s3"

  bucket_name             = local.s3_bucket_name
  elb_service_account_arn = data.aws_elb_service_account.root.arn
  common_tags             = local.common_tags
}

## aws_s3_bucket_object
resource "aws_s3_object" "weblog_bucket_objects" {
  for_each = {
    "website" = "website/index.html",
    "logo"    = "website/Globo_logo_Vert.png"
  }

  bucket = module.s3.bucket.id
  key    = each.value
  source = each.value

  tags = local.common_tags
}


