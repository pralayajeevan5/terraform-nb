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
  count                  = var.nginx_instance_count
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = var.nginx_instance_type
  subnet_id              = aws_subnet.subnets[(count.index % var.vpc_subnet_count)].id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx.name
  depends_on             = [aws_iam_instance_profile.nginx]
  tags                   = merge(local.common_tags, { Name = "${local.name_prefix}-nginx-${count.index}" })

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/templates/startup_script.tpl", {
    s3_bucket_name = aws_s3_bucket.weblog.id
  })
}
