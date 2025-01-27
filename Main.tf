provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

# Generate a dynamic SSH key pair for the instance
resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create the AWS key pair resource using the dynamically generated private key
resource "aws_key_pair" "generated_key" {
  key_name   = "flask-app-key"
  public_key = tls_private_key.generated_key.public_key_openssh
}

# Security Group to allow SSH access, HTTP traffic, and MySQL (3306) 
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2-security-group"
  description = "Allow SSH, HTTP, and MySQL access"
  
  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow MySQL access on port 3306
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance and associate the generated SSH key
resource "aws_instance" "flask_app" {
  ami           = "ami-0b898040803850657"  # Update with your desired AMI for Ubuntu 20.04
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.ec2_security_group.name]
  associate_public_ip_address  = true

  # User data for instance initialization
  user_data = file("terraform/user_data.sh")

  tags = {
    Name = "FlaskAppInstance"
  }

  # Wait for the instance to be in a 'running' state before proceeding with provisioning
  provisioner "local-exec" {
    command = "aws ec2 wait instance-running --instance-ids ${self.id}"
  }

  depends_on = [aws_key_pair.generated_key]
}

# Output the private key so you can save it for SSH access
output "private_key" {
  value     = tls_private_key.generated_key.private_key_pem
  sensitive = true
}

# Optional: Output the public IP of the EC2 instance for easy access
output "public_ip" {
  value = aws_instance.flask_app.public_ip
}
