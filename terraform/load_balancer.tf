# Application Load Balancer for production
resource "aws_lb" "prod" {
  name               = "prod"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.prod_lb.id]
  subnets            = [aws_subnet.prod_public_1.id, aws_subnet.prod_public_2.id]
}

# Target group for backend web application
resource "aws_lb_target_group" "prod_backend" {
  name        = "prod-backend"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.prod.id
  target_type = "ip"

  health_check {
    path                = "/ping/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200"
  }
}

# Target listener for https:443
resource "aws_lb_listener" "prod_https" {
  load_balancer_arn = aws_lb.prod.id
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  depends_on        = [aws_lb_target_group.prod_backend]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_backend.arn
  }
}

# Redirect HTTP to HTTPS
resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_lb.prod.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Redirect www to non-www
resource "aws_lb_listener_rule" "redirect_www_to_non_www" {
  listener_arn = aws_lb_listener.prod_https.arn

  action {
    type = "redirect"

    redirect {
      host        = "${var.domain}"
      status_code = "HTTP_301"
      port        = "443"
      protocol    = "HTTPS"
    }
  }

  condition {
    host_header {
      values = ["www.${var.domain}"]
    }
  }
}

# Allow traffic from 80 and 443 ports only
resource "aws_security_group" "prod_lb" {
  name        = "prod-lb"
  description = "Controls access to the ALB"
  vpc_id      = aws_vpc.prod.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
