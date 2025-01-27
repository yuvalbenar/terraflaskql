#!/bin/bash
# Update and install necessary dependencies
sudo yum update -y

# Install Docker
sudo yum install docker -y

# Start the Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Verify Docker is running
sudo systemctl status docker

# Add ec2-user to the docker group
sudo usermod -aG docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Set up the project files on the instance
mkdir -p /home/ec2-user/terraflaskql
cd /home/ec2-user/terraflaskql

# Clone the GitHub repository containing the Flask app
git clone https://github.com/yuvalbenar/terraflaskql.git .

# Build and start the Docker containers using docker-compose
sudo docker-compose up --build -d
