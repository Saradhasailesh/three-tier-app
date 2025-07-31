resource "aws_lb" "app_server_lb" {
  name               = "app-server-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_ids]
  subnets            = [var.public_subnet_id]
}

resource "aws_lb_target_group" "app_server_tg" {
  name     = "app-server-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type   = "instance"
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2

  }
  
}

resource "aws_lb_listener" "app_server_listener" {
  load_balancer_arn = aws_lb.app_server_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_server_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "lb_app_server_connect" {
  count = length(var.app_server_ids)
  target_group_arn = aws_lb_target_group.app_server_tg.arn
  target_id = var.app_server_ids[count.index]
  port = 80
}