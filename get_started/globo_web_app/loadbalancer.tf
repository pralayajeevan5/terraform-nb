###################################################################################
# DATA
##################################################################################

data "aws_elb_service_account" "root" {}

###################################################################################
# RESOURCES
##################################################################################

resource "aws_lb" "nginx" {
  name               = "nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.weblog.id
    prefix  = "alb-logs"
    enabled = true
  }

  tags = local.common_tags
}

## aws_lb_target_group
resource "aws_lb_target_group" "nginx" {
  name     = "nginx-alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

## aws_lb_listener
resource "aws_lb_listener" "nginx" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }
}

## aws_lb_target_group_attachment for nginx-1
resource "aws_lb_target_group_attachment" "nginx-1" {
  target_group_arn = aws_lb_target_group.nginx.arn
  target_id        = aws_instance.nginx-1.id
  port             = 80
}

## aws_lb_target_group_attachment for nginx-2
resource "aws_lb_target_group_attachment" "nginx-2" {
  target_group_arn = aws_lb_target_group.nginx.arn
  target_id        = aws_instance.nginx-2.id
  port             = 80
}
