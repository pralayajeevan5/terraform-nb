###############################################################################
# PROVIDERS 
###############################################################################


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.0"
    }
  }

  backend "consul" {
    address = "127.0.0.1:8500"
    scheme  = "http"
  }
}

provider "aws" {
  profile = "deep-dive"
  region  = var.region
}

###############################################################################
# LOCALS 
###############################################################################

locals {
  asg_instance_size = jsondecode(data.consul_keys.applications.var.applications)["asg_instance_size"]
  asg_max_size      = jsondecode(data.consul_keys.applications.var.applications)["asg_max_size"]
  asg_min_size      = jsondecode(data.consul_keys.applications.var.applications)["asg_min_size"]
  rds_storage_size  = jsondecode(data.consul_keys.applications.var.applications)["rds_storage_size"]
  rds_engine        = jsondecode(data.consul_keys.applications.var.applications)["rds_engine"]
  rds_version       = jsondecode(data.consul_keys.applications.var.applications)["rds_version"]
  rds_instance_size = jsondecode(data.consul_keys.applications.var.applications)["rds_instance_size"]
  rds_multi_az      = jsondecode(data.consul_keys.applications.var.applications)["rds_multi_az"]
  rds_db_name       = jsondecode(data.consul_keys.applications.var.applications)["rds_db_name"]

  common_tags = merge(
    { Environment = terraform.workspace },
    jsondecode(data.consul_keys.applications.var.common_tags)
  )
}

###############################################################################
# RESOURCE
###############################################################################

resource "aws_launch_template" "webapp_lt" {
  name_prefix   = "ddt-webapp-lt-${terraform.workspace}-"
  image_id      = data.aws_ami.aws_linux.id
  instance_type = local.asg_instance_size

  user_data = filebase64("./templates/userdata.sh")

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      aws_security_group.webapp_http_inbound_sg.id,
      aws_security_group.webapp_ssh_inbound_sg.id,
      aws_security_group.webapp_outbound_sg.id
    ]
  }
}

resource "aws_autoscaling_group" "webapp_asg" {
  lifecycle {
    create_before_destroy = true
  }

  vpc_zone_identifier = data.terraform_remote_state.networking.outputs.public_subnet_ids
  name                = "ddt-webapp-asg-${terraform.workspace}"
  max_size            = local.asg_max_size
  min_size            = local.asg_min_size
  force_delete        = true
  load_balancers      = [aws_elb.webapp_elb.name]

  launch_template {
    id      = aws_launch_template.webapp_lt.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_elb" "webapp_elb" {
  name    = "ddt-webapp-elb-${terraform.workspace}"
  subnets = data.terraform_remote_state.networking.outputs.public_subnet_ids

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

  security_groups = [
    aws_security_group.webapp_http_inbound_sg.id,
  ]

  tags = local.common_tags
}


#
# Scale Up Policy and Alarm
#
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "ddt_asg_scale_up-${terraform.workspace}"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name                = "ddt-high-asg-cpu-${terraform.workspace}"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}

#
# Scale Down Policy and Alarm
#
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "ddt_asg_scale_down-${terraform.workspace}"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 600
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name                = "ddt-low-asg-cpu-${terraform.workspace}"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "5"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "30"
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}

## Database Config 

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${terraform.workspace}-ddt-rds-subnet-group"
  subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids
}

resource "aws_db_instance" "rds" {
  identifier             = "${terraform.workspace}-ddt-rds"
  allocated_storage      = local.rds_storage_size
  engine                 = local.rds_engine
  engine_version         = local.rds_version
  instance_class         = local.rds_instance_size
  multi_az               = local.rds_multi_az
  username               = var.rds_username
  password               = var.rds_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true

  tags = local.common_tags
}

