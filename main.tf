# Provider configuration for AWS
provider "aws" {
  region         = "us-east-1" # Change this to your desired AWS region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# terraform {
#   backend "s3" {
#     bucket         = "clusters.cadnewera.dev.org"
#     key            = "path/to/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "abda-smart-technology"
#   }
# }


resource "aws_instance" "Bartuah-dev-server" {
  ami           = "ami-0620781df87f2f102" # Replace with your AMI ID
  instance_type = "t2.micro"               # Replace with your desired instance type
  tags = {
    Name = "Cloud_Ops"
  }
}
  




# Create a security group
# resource "aws_security_group" "web_sg" {
#   name        = "web_security_group"
#   description = "Allow inbound HTTP traffic"

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# Launch Configuration
resource "aws_launch_configuration" "web_server_lc" {
  name_prefix     = "web-server-lc-"
  image_id        = "ami-0759f51a90924c166" # Change this to your desired AMI
  instance_type   = "t2.micro"              # Change this to your desired instance type
  security_groups = [aws_security_group.web_sg.id]
  user_data       = <<-EOF
                                  #!/bin/bash
                                  yum update -y
                                  yum install -y httpd
                                  systemctl start httpd
                                  systemctl enable httpd
                                EOF

  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaling Group
resource "aws_autoscaling_group" "web_server_asg" {
  desired_capacity     = 2
  min_size             = 1
  max_size             = 4
  launch_configuration = aws_launch_configuration.web_server_lc.id
  vpc_zone_identifier  = ["subnet-014ddf1af0d42cfc8"] # Replace with your subnet ID

  tag {
    key                 = "Name"
    value               = "web-server"
    propagate_at_launch = true
  }
}

# # Load Balancer
# resource "aws_lb" "web_lb" {
#   name               = "web-load-balancer"
#   internal           = false
#   load_balancer_type = "application"
#   subnets            = ["subnet-014ddf1af0d42cfc8", "subnet-0ff2152d520c63113"] # Replace with your subnet IDs
# }

# # Load Balancer Listener
# resource "aws_lb_listener" "web_lb_listener" {
#   load_balancer_arn = aws_lb.web_lb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.web_target_group.arn
#   }
# }

# # Target Group
# resource "aws_lb_target_group" "web_target_group" {
#   name     = "web-target-group"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = "vpc-0a51aa34482504882" # Replace with your VPC ID

#   health_check {
#     path                = "/"
#     protocol            = "HTTP"
#     port                = "traffic-port"
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     timeout             = 3
#     interval            = 30
#   }
# }

# # Route 53 Record
# resource "aws_route53_record" "web_dns_record" {
#   zone_id = "Z02552193DAG9XJT8SX07" # Replace with your Route 53 hosted zone ID
#   name    = "zuahserkah.com"        # Replace with your desired domain name
#   type    = "A"

#   alias {
#     name                   = aws_lb.web_lb.dns_name
#     zone_id                = aws_lb.web_lb.zone_id
#     evaluate_target_health = true
#   }
# }
