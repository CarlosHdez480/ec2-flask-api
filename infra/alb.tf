resource "aws_security_group" "alb_sg" {
  name        = "alb-flask-sg"
  description = "Allow HTTP traffic to Load Balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["89.129.99.43/32"]
    description = "Allow HTTP traffic from the internet"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Load-Balancer-Security-Group"
  }
}

### Load Balancer ###
resource "aws_lb" "flask_lb" {
  name               = "flask-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.public_subnets.ids # Replace with valid subnet IDs

  tags = {
    Name = "Flask-Load-Balancer"
  }
}

### Target Group ###
resource "aws_lb_target_group" "flask_tg" {
  name     = "flask-target-group"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_tenancy_vpc.id
  health_check {
    path                = "/healthcheck"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = {
    Name = "Flask-Target-Group"
  }
}

### Attach EC2 Instance to Target Group ###
resource "aws_lb_target_group_attachment" "flask_tg_attachment" {
  target_group_arn = aws_lb_target_group.flask_tg.arn
  target_id        = aws_instance.flask_service.id
  port             = 5000
}

### Listener for Load Balancer ###
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.flask_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask_tg.arn
  }
}

### Outputs ###
output "load_balancer_dns" {
  value = aws_lb.flask_lb.dns_name
}
