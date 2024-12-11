#!/bin/bash
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -aG docker ec2-user

curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${ecr_registry}

cat > /home/ec2-user/docker-compose.yml << 'EOF'
version: "3.9"
services:
  web:
    image: ${ecr_registry}/${image_name}:latest
    container_name: flask_app
    expose:
      - "5000"

  nginx:
    image: nginx:stable-alpine
    container_name: nginx_proxy
    ports:
      - "80:80"
    depends_on:
      - web
    volumes:
      - /home/ec2-user/nginx.conf:/etc/nginx/conf.d/default.conf:ro
EOF

cat > /home/ec2-user/nginx.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    location / {
        proxy_pass http://web:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

chown ec2-user:ec2-user /home/ec2-user/docker-compose.yml /home/ec2-user/nginx.conf
cd /home/ec2-user
sudo -u ec2-user /usr/local/bin/docker-compose up -d
