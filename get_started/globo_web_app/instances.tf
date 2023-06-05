#################################################################
# DATA 
#################################################################

data "aws_ssm_parameter" "ami" {
  name = var.ami_ssm_parameter
}

#################################################################
# Resources
#################################################################

resource "aws_instance" "nginx_servers" {
  count                  = var.nginx_instance_count[terraform.workspace]
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = var.nginx_instance_type[terraform.workspace]
  subnet_id              = module.vpc.public_subnets[(count.index % var.vpc_subnet_count[terraform.workspace])]
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  depends_on             = [module.s3]
  iam_instance_profile   = module.s3.instance_profile.name
  tags                   = merge(local.common_tags, { Name = "${local.name_prefix}-nginx-${count.index}" })

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/templates/startup_script.tpl", {
    s3_bucket_name = module.s3.bucket.id
  })
}
