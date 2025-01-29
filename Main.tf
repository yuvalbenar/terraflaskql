provider "aws" {
  region = "us-east-1"  # Update to your desired region
}

# Generate a random suffix for the security group name
resource "random_id" "sg_suffix" {
  byte_length = 4
}

# Define the security group for the Flask app
resource "aws_security_group" "flask_sg" {
  name        = "flask-app-sg-tf-${random_id.sg_suffix.hex}"  # Using the random suffix here
  description = "Security group for Flask app"

  ingress {
    from_port   = 3306  # MySQL port if needed
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust CIDR block as needed
  }

  ingress {
    from_port   = 5000  # Flask app port
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443  # HTTPS port
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80   # HTTP port
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22   # SSH port
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting access to specific IPs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance to run the Flask app
resource "aws_instance" "flask_instance" {
  ami           = "ami-01816d07b1128cd2d"  # Update with your chosen Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = "privatekeyterra"  # Reference your existing key pair by name

  security_groups = [aws_security_group.flask_sg.name]

  iam_instance_profile = "access-to-s3"  # IAM role to access S3 for .env file and private key

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y git docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user
              newgrp docker
              yum install -y libxcrypt-compat
              curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              git clone https://github.com/yuvalbenar/terraflaskql.git /home/ec2-user/terraflaskql
              aws s3 cp s3://terraflaskql-privatekey/.env /home/ec2-user/terraflaskql/.env  # Adjusted S3 path
              cd /home/ec2-user/terraflaskql
              docker-compose up -d
              EOF

  tags = {
    Name = "FlaskAppInstance"
  }
}

# Output the public IP of the EC2 instance
output "instance_public_ip" {
  value       = aws_instance.flask_instance.public_ip
  description = "Public IP of the EC2 instance"
}
