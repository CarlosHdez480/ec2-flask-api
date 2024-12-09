resource "aws_security_group" "allow_http" {
  name        = "flask-api-sg"
  description = "Allow HTTP traffic"

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "Allow HTTP traffic from Load Balancer"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    project = "flask-api"
  }
}

resource "aws_instance" "flask_service" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"

  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.allow_http.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              service docker start
              usermod -a -G docker ec2-user
              $(aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com)
              docker pull ${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/${var.repository_name}:latest
              docker run -d -p 80:5000 ${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/${var.repository_name}:latest
              EOF

  tags = {
    project = "flask-api"
  }
}

output "instance_ip" {
  value = aws_instance.flask_service.public_ip
}