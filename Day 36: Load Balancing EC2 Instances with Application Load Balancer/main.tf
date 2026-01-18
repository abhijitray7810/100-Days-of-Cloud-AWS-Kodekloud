terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Data source to get default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source to get default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Data source to get default security group
data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

# Data source to get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for EC2 instance
resource "aws_security_group" "devops_sg" {
  name        = "devops-sg"
  description = "Security group for DevOps EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [data.aws_security_group.default.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-sg"
  }
}

# Security Group Rule - Allow HTTP traffic to default security group (for ALB)
resource "aws_security_group_rule" "alb_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.default.id
  description       = "Allow HTTP traffic from internet to ALB"
}

# EC2 Instance
resource "aws_instance" "devops_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.devops_sg.id]
  
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Hello from DevOps EC2 Instance</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "devops-ec2"
  }
}

# Target Group
resource "aws_lb_target_group" "devops_tg" {
  name     = "devops-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "devops-tg"
  }
}

# Target Group Attachment
resource "aws_lb_target_group_attachment" "devops_tg_attachment" {
  target_group_arn = aws_lb_target_group.devops_tg.arn
  target_id        = aws_instance.devops_ec2.id
  port             = 80
}

# Application Load Balancer
resource "aws_lb" "devops_alb" {
  name               = "devops-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.default.id]
  subnets            = data.aws_subnets.default.ids

  enable_deletion_protection = false

  tags = {
    Name = "devops-alb"
  }
}

# ALB Listener
resource "aws_lb_listener" "devops_listener" {
  load_balancer_arn = aws_lb.devops_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.devops_tg.arn
  }
}

# Kinesis Data Stream
resource "aws_kinesis_stream" "nautilus_stream" {
  name             = "nautilus-stream"
  shard_count      = 1
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "IncomingRecords",
    "OutgoingBytes",
    "OutgoingRecords",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = {
    Name        = "nautilus-stream"
    Environment = "production"
    ManagedBy   = "Terraform"
    Team        = "DevOps"
  }
}

# SNS Topic
resource "aws_sns_topic" "nautilus_notifications" {
  name = "nautilus-notifications"

  tags = {
    Name        = "nautilus-notifications"
    Environment = "production"
    ManagedBy   = "Terraform"
    Team        = "DevOps"
  }
}

# Outputs for EC2 and ALB
output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.devops_ec2.id
}

output "ec2_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.devops_ec2.public_ip
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.devops_alb.dns_name
}

output "alb_url" {
  description = "The URL to access the application via ALB"
  value       = "http://${aws_lb.devops_alb.dns_name}"
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.devops_tg.arn
}

# Outputs for Kinesis Stream
output "stream_name" {
  description = "The name of the Kinesis stream"
  value       = aws_kinesis_stream.nautilus_stream.name
}

output "stream_arn" {
  description = "The ARN of the Kinesis stream"
  value       = aws_kinesis_stream.nautilus_stream.arn
}

# Outputs for SNS Topic
output "sns_topic_name" {
  description = "The name of the SNS topic"
  value       = aws_sns_topic.nautilus_notifications.name
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic"
  value       = aws_sns_topic.nautilus_notifications.arn
}
