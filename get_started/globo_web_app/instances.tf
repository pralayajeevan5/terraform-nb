#################################################################
# DATA 
#################################################################

data "aws_ssm_parameter" "ami" {
  name = var.ami_ssm_parameter
}

#################################################################
# Resources
#################################################################

resource "aws_instance" "nginx-1" {
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = var.nginx_instance_type
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx.name
  depends_on             = [aws_iam_instance_profile.nginx, aws_s3_object.website_index, aws_s3_object.website_logo]
  tags                   = local.common_tags

  user_data_replace_on_change = true
  user_data                   = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
aws s3 cp s3://${aws_s3_bucket.weblog.id}/website/index.html /home/ec2-user/index.html
aws s3 cp s3://${aws_s3_bucket.weblog.id}/website/Globo_logo_Vert.png /home/ec2-user/Globo_logo_Vert.png
sudo rm /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/Globo_logo_Vert.png /usr/share/nginx/html/Globo_logo_Vert.png
EOF
}

resource "aws_instance" "nginx-2" {
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = var.nginx_instance_type
  subnet_id              = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx.name
  depends_on             = [aws_iam_instance_profile.nginx, aws_s3_object.website_index, aws_s3_object.website_logo]
  tags                   = local.common_tags

  user_data_replace_on_change = true
  user_data                   = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
aws s3 cp s3://${aws_s3_bucket.weblog.id}/website/index.html /home/ec2-user/index.html
aws s3 cp s3://${aws_s3_bucket.weblog.id}/website/Globo_logo_Vert.png /home/ec2-user/Globo_logo_Vert.png
sudo rm /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/Globo_logo_Vert.png /usr/share/nginx/html/Globo_logo_Vert.png
EOF
}
